



import 'dart:convert';
import 'dart:async';
import 'package:apps/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:provider/provider.dart';
import '../../providers/interview_provider.dart';
import '../../theme/app_theme.dart';
import '../../services/env_service.dart';
import 'interview_results.dart';

const _groqUrl = 'https://api.groq.com/openai/v1/chat/completions';
const _model = 'llama-3.1-8b-instant';

class InterviewSession extends StatefulWidget {
  final String topic;
  const InterviewSession({super.key, required this.topic});

  @override
  State<InterviewSession> createState() => _InterviewSessionState();
}

class _InterviewSessionState extends State<InterviewSession> {
  List<String> _questions = [];
  int _currentIndex = 0;
  bool _loading = true;
  bool _evaluating = false;
  String? _feedback;
  int? _score;
  bool _answered = false;
  final List<Map<String, dynamic>> _results = [];
  int _totalScore = 0;
  String _loadingMsg = 'Generating questions…';

  final TextEditingController _answerCtrl = TextEditingController();
  final FlutterTts _tts = FlutterTts();
  final SpeechToText _stt = SpeechToText();
  bool _sttAvailable = false;
  bool _listening = false;

  CameraController? _camCtrl;
  bool _cameraReady = false;
  bool _faceVisible = true;
  bool _showWarning = false;
  Timer? _faceTimer;
  int _missedFrames = 0;
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(performanceMode: FaceDetectorMode.fast),
  );
  bool _processingFrame = false;

  @override
  void initState() {
    super.initState();
    _initAll();
  }

  Future<void> _initAll() async {
    await _initTts();
    await _initStt();
    await _initCamera();
    await _generateQuestions();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.48);
    await _tts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> _initStt() async {
    _sttAvailable = await _stt.initialize(
      onError: (_) => setState(() => _listening = false),
    );
  }

  void _toggleMic() {
    if (!_sttAvailable) {
      _snack('Speech recognition not available on this device');
      return;
    }
    _listening ? _stopListening() : _startListening();
  }

  void _startListening() async {
    await _tts.stop();
    setState(() => _listening = true);
    await _stt.listen(
      onResult: (r) {
        if (r.finalResult) {
          final existing = _answerCtrl.text;
          _answerCtrl.text = ('$existing ${r.recognizedWords}').trimLeft();
          _answerCtrl.selection = TextSelection.fromPosition(
            TextPosition(offset: _answerCtrl.text.length),
          );
        }
      },
      listenFor: const Duration(minutes: 3),
      pauseFor: const Duration(seconds: 4),
      partialResults: false,
    );
  }

  void _stopListening() async {
    await _stt.stop();
    setState(() => _listening = false);
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      _camCtrl = CameraController(
        front,
        ResolutionPreset.low,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21,
      );
      await _camCtrl!.initialize();
      if (mounted) setState(() => _cameraReady = true);
      _faceTimer = Timer.periodic(
        const Duration(seconds: 2),
        (_) => _checkFace(),
      );
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  Future<void> _checkFace() async {
    if (_camCtrl == null || !_camCtrl!.value.isInitialized || _processingFrame) {
      return;
    }
    _processingFrame = true;
    try {
      final xFile = await _camCtrl!.takePicture();
      final inputImg = InputImage.fromFilePath(xFile.path);
      final faces = await _faceDetector.processImage(inputImg);
      final found = faces.isNotEmpty;
      if (mounted) {
        setState(() => _faceVisible = found);
        if (found) {
          _missedFrames = 0;
          if (_showWarning) setState(() => _showWarning = false);
        } else {
          _missedFrames++;
          if (_missedFrames >= 3 && !_showWarning) {
            setState(() => _showWarning = true);
            _speak(
              'Warning! Your face is not visible. Please keep your face in the camera during the interview.',
            );
          }
        }
      }
    } catch (_) {
    } finally {
      _processingFrame = false;
    }
  }

  void _stopCamera() {
    _faceTimer?.cancel();
    _faceDetector.close();
    _camCtrl?.dispose();
    _camCtrl = null;
  }

  Future<String> _groq(
    List<Map<String, String>> messages, {
    int maxTokens = 600,
  }) async {
    final res = await http
        .post(
          Uri.parse(_groqUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${EnvService.groqApiKey}',
          },
          body: jsonEncode({
            'model': _model,
            'max_tokens': maxTokens,
            'temperature': 0.7,
            'messages': messages,
          }),
        )
        .timeout(const Duration(seconds: 25));

    if (res.statusCode != 200) {
      final err = jsonDecode(res.body);
      throw Exception(
        err['error']?['message'] ?? 'Groq API error ${res.statusCode}',
      );
    }
    final data = jsonDecode(res.body);
    return data['choices'][0]['message']['content'].toString().trim();
  }

  Future<void> _generateQuestions() async {
    setState(() {
      _loading = true;
      _loadingMsg = 'Generating questions…';
    });
    try {
      final raw = await _groq([
        {
          'role': 'user',
          'content':
              'You are a senior technical interviewer. Generate exactly 5 interview questions for the topic: "${widget.topic}". Return ONLY a JSON array of 5 strings, no markdown, no extra text. Example: ["Q1?","Q2?","Q3?","Q4?","Q5?"]',
        },
      ], maxTokens: 800);

      List<String> questions;
      try {
        final cleaned = raw.replaceAll(RegExp(r'```json|```'), '').trim();
        questions = List<String>.from(jsonDecode(cleaned));
      } catch (_) {
        final matches = RegExp(r'"([^"]+?\?)"').allMatches(raw);
        questions = matches.map((m) => m.group(1)!).toList();
        if (questions.length < 3) {
          throw Exception('Could not parse questions from AI response.');
        }
      }

      setState(() {
        _questions = questions.take(5).toList();
        _loading = false;
        _currentIndex = 0;
      });

      await _speak('Question 1. ${_questions[0]}');
    } catch (e) {
      if (mounted) {
        _snack('Error: $e');
        Navigator.pop(context);
      }
    }
  }

  Future<void> _submitAnswer() async {
    _stopListening();
    await _tts.stop();
    final answer = _answerCtrl.text.trim();
    if (answer.isEmpty) {
      _snack('Please type or speak your answer first');
      return;
    }

    setState(() {
      _evaluating = true;
      _feedback = null;
      _score = null;
    });

    try {
      final q = _questions[_currentIndex];
      final raw = await _groq([
        {
          'role': 'user',
          'content':
              'You are a strict but fair technical interviewer evaluating an interview answer.\n\nTopic: ${widget.topic}\nQuestion: $q\nCandidate\'s Answer: $answer\n\nEvaluate and respond ONLY with valid JSON, no markdown:\n{"score": <0-10>, "feedback": "<2-3 sentences: what was good and what was missing>"}',
        },
      ], maxTokens: 400);

      Map<String, dynamic> result;
      try {
        result = jsonDecode(raw.replaceAll(RegExp(r'```json|```'), '').trim());
      } catch (_) {
        final sm = RegExp(r'"score"\s*:\s*(\d+)').firstMatch(raw);
        final fm = RegExp(r'"feedback"\s*:\s*"([^"]+)"').firstMatch(raw);
        result = {
          'score': sm != null ? int.parse(sm.group(1)!) : 5,
          'feedback': fm?.group(1) ?? 'No feedback.',
        };
      }

      final score = (result['score'] as num).clamp(0, 10).toInt();
      final feedback = result['feedback'].toString();

      _results.add({
        'question': q,
        'answer': answer,
        'score': score,
        'feedback': feedback,
      });
      _totalScore += score;

      setState(() {
        _score = score;
        _feedback = feedback;
        _answered = true;
        _evaluating = false;
      });
    } catch (e) {
      setState(() => _evaluating = false);
      _snack('Evaluation error: $e');
    }
  }

  void _nextQuestion() async {
    setState(() {
      _currentIndex++;
      _answered = false;
      _feedback = null;
      _score = null;
      _answerCtrl.clear();
    });
    await _speak('Question ${_currentIndex + 1}. ${_questions[_currentIndex]}');
  }

  void _finish() {
    _stopCamera();
    _tts.stop();

    // Save to provider
    final interviewProvider = Provider.of<InterviewProvider>(
      context,
      listen: false,
    );
    interviewProvider.addInterviewResult(
      topic: widget.topic,
      totalScore: _totalScore,
      maxScore: _questions.length * 10,
      results: _results,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => InterviewResults(
          topic: widget.topic,
          results: _results,
          totalScore: _totalScore,
          maxScore: _questions.length * 10,
        ),
      ),
    );
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppTheme.errorColor),
    );
  }

  @override
  void dispose() {
    _stopListening();
    _tts.stop();
    _stopCamera();
    _answerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.darkBackground
          : AppTheme.lightBackground,
      body: Stack(
        children: [
          SafeArea(
            child: _loading
                ? _buildLoading(isDark)
                : Column(
                    children: [
                      _buildTopBar(isDark),
                      Expanded(child: _buildBody(isDark)),
                    ],
                  ),
          ),
          if (_cameraReady && !_loading)
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              right: 12,
              child: _buildCameraWidget(isDark),
            ),
          if (_showWarning)
            Positioned(top: 0, left: 0, right: 0, child: _buildFaceWarning()),
        ],
      ),
    );
  }

  Widget _buildLoading(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              color: AppTheme.primaryColor,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _loadingMsg,
            style: TextStyle(
              color: isDark ? AppTheme.darkTextLight : AppTheme.lightTextLight,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(bool isDark) {
    final total = _questions.length;
    final progress = total > 0 ? (_currentIndex / total) : 0.0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'QUESTION ${_currentIndex + 1} OF $total',
                style: TextStyle(
                  color: isDark
                      ? AppTheme.darkTextLight
                      : AppTheme.lightTextLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'SCORE: $_totalScore / ${_results.length * 10}',
                style: TextStyle(
                  color: isDark
                      ? AppTheme.darkTextLight
                      : AppTheme.lightTextLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: isDark
                ? AppTheme.darkDivider
                : AppTheme.lightDivider,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuestionCard(isDark),
          const SizedBox(height: 20),
          if (!_answered) ...[
            _buildAnswerInput(isDark),
            const SizedBox(height: 16),
            if (_evaluating)
              _buildLoadingRow(isDark)
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitAnswer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'SUBMIT ANSWER',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
          ],
          if (_answered && _feedback != null) ...[
            _buildFeedbackCard(isDark),
            const SizedBox(height: 16),
            Row(
              children: [
                if (_currentIndex < _questions.length - 1)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _nextQuestion,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark
                            ? AppTheme.darkText
                            : AppTheme.lightText,
                        side: BorderSide(
                          color: isDark
                              ? AppTheme.darkDivider
                              : AppTheme.lightDivider,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('NEXT QUESTION →'),
                    ),
                  )
                else
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _finish,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'FINISH & VIEW RESULTS',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.darkDivider : AppTheme.lightDivider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'QUESTION ${_currentIndex + 1}',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              GestureDetector(
                onTap: () => _speak(
                  'Question ${_currentIndex + 1}. ${_questions[_currentIndex]}',
                ),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.volume_up_outlined,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _questions[_currentIndex],
            style: TextStyle(
              color: isDark ? AppTheme.darkText : AppTheme.lightText,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerInput(bool isDark) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _listening
                  ? AppTheme.errorColor
                  : (isDark ? AppTheme.darkDivider : AppTheme.lightDivider),
              width: _listening ? 2 : 1,
            ),
          ),
          child: TextField(
            controller: _answerCtrl,
            maxLines: 5,
            style: TextStyle(
              color: isDark ? AppTheme.darkText : AppTheme.lightText,
              fontSize: 15,
              height: 1.5,
            ),
            decoration: InputDecoration(
              hintText: _listening
                  ? 'Listening... speak now'
                  : 'Type your answer here... or tap 🎤 to speak',
              hintStyle: TextStyle(
                color: isDark
                    ? AppTheme.darkTextLight
                    : AppTheme.lightTextLight,
                fontSize: 14,
              ),
              contentPadding: const EdgeInsets.only(
                left: 16,
                top: 16,
                right: 50,
                bottom: 16,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          right: 10,
          child: GestureDetector(
            onTap: _toggleMic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _listening
                    ? AppTheme.errorColor.withOpacity(0.1)
                    : (isDark ? AppTheme.darkSurface : Colors.grey.shade100),
                border: Border.all(
                  color: _listening
                      ? AppTheme.errorColor
                      : AppTheme.primaryColor,
                ),
              ),
              child: Icon(
                _listening ? Icons.mic : Icons.mic_none,
                color: _listening ? AppTheme.errorColor : AppTheme.primaryColor,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackCard(bool isDark) {
    final score = _score ?? 0;
    final Color scoreColor = score >= 8
        ? AppTheme.secondaryColor
        : score >= 5
        ? AppTheme.warningColor
        : AppTheme.errorColor;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.darkDivider : AppTheme.lightDivider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AI FEEDBACK',
                style: TextStyle(
                  color: isDark
                      ? AppTheme.darkTextLight
                      : AppTheme.lightTextLight,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: scoreColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: scoreColor),
                ),
                child: Text(
                  '$score / 10',
                  style: TextStyle(
                    color: scoreColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _feedback ?? '',
            style: TextStyle(
              color: isDark ? AppTheme.darkTextLight : AppTheme.lightTextLight,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraWidget(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 100,
          height: 75,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _faceVisible ? AppTheme.primaryColor : AppTheme.errorColor,
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: CameraPreview(_camCtrl!),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color:
                (_faceVisible ? AppTheme.secondaryColor : AppTheme.errorColor)
                    .withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _faceVisible ? 'FACE DETECTED' : 'NO FACE',
            style: TextStyle(
              color: _faceVisible
                  ? AppTheme.secondaryColor
                  : AppTheme.errorColor,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFaceWarning() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppTheme.errorColor,
      child: Row(
        children: const [
          Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              '⚠ FACE NOT DETECTED — Keep your face visible during the interview!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingRow(bool isDark) {
    return Row(
      children: [
        const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            color: AppTheme.primaryColor,
            strokeWidth: 2,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'EVALUATING YOUR ANSWER...',
          style: TextStyle(
            color: isDark ? AppTheme.darkTextLight : AppTheme.lightTextLight,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}