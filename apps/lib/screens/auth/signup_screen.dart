import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget
{
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
{
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;

  String? _errorMessage;

  @override
  void dispose()
  {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async
  {
    if (!_formKey.currentState!.validate())
    {
      return;
    }

    if (!_agreedToTerms)
    {
      setState(() {
        _errorMessage = "Please accept Terms and Conditions";
      });
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text)
    {
      setState(() {
        _errorMessage = "Passwords do not match";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await AuthService.signup(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (result['success'])
    {
      if (mounted)
      {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account created successfully")),
        );

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
    else
    {
      setState(() {
        _errorMessage = result['message'];
      });
    }
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,

      body: SafeArea(
        child: SingleChildScrollView(

          padding: const EdgeInsets.all(24),

          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,

              children: [

                const SizedBox(height: 30),

                Text(
                  "Create Account",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: const Color.fromRGBO(108, 92, 231, 1),
                      ),
                ),

                const SizedBox(height: 10),

                Text(
                  "Join thousands of students preparing for placements",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                const SizedBox(height: 30),

                TextFormField(
                  controller: _nameController,

                  decoration: const InputDecoration(
                    labelText: "Full Name",
                    hintText: "John Doe",
                    prefixIcon: Icon(Icons.person_outline),
                  ),

                  validator: (value)
                  {
                    if (value == null || value.isEmpty)
                    {
                      return "Enter your name";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,

                  decoration: const InputDecoration(
                    labelText: "Email Address",
                    hintText: "example@email.com",
                    prefixIcon: Icon(Icons.email_outlined),
                  ),

                  validator: (value)
                  {
                    if (value == null || value.isEmpty)
                    {
                      return "Enter email";
                    }

                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value))
                    {
                      return "Invalid email";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,

                  decoration: InputDecoration(
                    labelText: "Password",
                    hintText: "Minimum 6 characters",
                    prefixIcon: const Icon(Icons.lock_outline),

                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),

                      onPressed: ()
                      {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),

                  validator: (value)
                  {
                    if (value == null || value.length < 6)
                    {
                      return "Password must be 6 characters";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,

                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    prefixIcon: const Icon(Icons.lock_outline),

                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),

                      onPressed: ()
                      {
                        setState(() {
                          _obscureConfirmPassword =
                              !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),

                  validator: (value)
                  {
                    if (value == null || value.isEmpty)
                    {
                      return "Confirm password";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                Row(
                  children: [

                    Checkbox(
                      value: _agreedToTerms,

                      onChanged: (value)
                      {
                        setState(() {
                          _agreedToTerms = value ?? false;
                        });
                      },
                    ),

                    Expanded(
                      child: Text(
                        "I agree to Terms and Conditions",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    )

                  ],
                ),

                const SizedBox(height: 10),

                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: AppTheme.errorColor),
                  ),

                const SizedBox(height: 16),

                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignup,

                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text("Create Account"),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [

                    Text(
                      "Already have an account?",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),

                    TextButton(
                      onPressed: ()
                      {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },

                      child: const Text("Sign In"),
                    )

                  ],
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}