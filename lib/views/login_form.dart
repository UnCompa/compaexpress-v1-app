import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginForm extends StatefulWidget {
  final void Function(String email, String password)? onLogin;
  final bool isLoading;

  const LoginForm({super.key, this.onLogin, required this.isLoading});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Colores del tema InvoExpress
  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color lightBlue = Color(0xFF42A5F5);
  static const Color darkBlue = Color(0xFF0D47A1);
  static const Color backgroundBlue = Color(0xFFF3F8FF);

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.onLogin != null) {
      widget.onLogin!(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (KeyEvent event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.enter) {
            if (_formKey.currentState!.validate()) {
              _handleLogin();
            }
          }
        },
        child: Stack(
          children: [
            // Imagen de fondo con overlay
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1554224155-6726b3ff858f?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2726&q=80',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Overlay con gradiente
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    darkBlue.withOpacity(0.8),
                    primaryBlue.withOpacity(0.7),
                    lightBlue.withOpacity(0.6),
                  ],
                ),
              ),
            ),

            // Elementos decorativos flotantes
            Positioned(
              top: 100,
              right: 50,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.business_center_outlined,
                    size: 60,
                    color: Colors.white24,
                  ),
                ),
              ),
            ),

            Positioned(
              top: 200,
              left: 30,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.trending_up,
                    size: 40,
                    color: Colors.white24,
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 150,
              right: 20,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.account_balance_outlined,
                    size: 50,
                    color: Colors.white24,
                  ),
                ),
              ),
            ),

            // Contenido principal
            Center(
              child: SingleChildScrollView(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 420),
                      margin: const EdgeInsets.all(24),
                      child: Card(
                        elevation: 24,
                        shadowColor: darkBlue.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                theme.colorScheme.surface,
                                theme.colorScheme.surface.withOpacity(0.2),
                              ],
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: Stack(
                              children: [
                                // Patrón decorativo en la esquina superior
                                Positioned(
                                  top: -50,
                                  right: -50,
                                  child: Container(
                                    width: 150,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          lightBlue.withOpacity(0.1),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // Contenido del formulario
                                Padding(
                                  padding: const EdgeInsets.all(36),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Logo animado de InvoExpress
                                        Container(
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              24,
                                            ),
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [primaryBlue, lightBlue],
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: primaryBlue.withOpacity(
                                                  0.4,
                                                ),
                                                blurRadius: 16,
                                                offset: const Offset(0, 8),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.receipt_long_rounded,
                                            size: 52,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 28),

                                        // Título InvoExpress con efecto
                                        ShaderMask(
                                          shaderCallback: (bounds) =>
                                              LinearGradient(
                                                colors: [
                                                  primaryBlue,
                                                  lightBlue,
                                                ],
                                              ).createShader(bounds),
                                          child: Text(
                                            "CompaExpress",
                                            style: GoogleFonts.poppins(
                                              fontSize: 30,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                              letterSpacing: -1.0,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),

                                        // Subtítulo con decoración
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: primaryBlue.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            border: Border.all(
                                              color: primaryBlue.withOpacity(
                                                0.2,
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            "Gestión de facturas simplificada",
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: primaryBlue,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),

                                        // Título del formulario
                                        Text(
                                          "Bienvenido de nuevo",
                                          style: GoogleFonts.poppins(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            color: darkBlue,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "Inicia sesión para continuar",
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400,
                                            color: primaryBlue.withOpacity(0.7),
                                          ),
                                        ),
                                        const SizedBox(height: 32),

                                        // Campo Email mejorado
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: primaryBlue.withOpacity(
                                                  0.1,
                                                ),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: TextFormField(
                                            controller: _emailController,
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            decoration: InputDecoration(
                                              labelText: 'Correo electrónico',
                                              labelStyle: TextStyle(
                                                color: primaryBlue,
                                              ),
                                              prefixIcon: Container(
                                                margin: const EdgeInsets.all(
                                                  12,
                                                ),
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: primaryBlue
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Icon(
                                                  Icons.email_outlined,
                                                  color: primaryBlue,
                                                  size: 20,
                                                ),
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                                borderSide: BorderSide.none,
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                                borderSide: BorderSide.none,
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                                borderSide: BorderSide(
                                                  color: primaryBlue,
                                                  width: 2,
                                                ),
                                              ),
                                              errorBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                                borderSide: const BorderSide(
                                                  color: Colors.red,
                                                ),
                                              ),
                                              filled: true,
                                              fillColor: theme.scaffoldBackgroundColor,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 18,
                                                  ),
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Campo obligatorio';
                                              }
                                              if (!value.contains('@')) {
                                                return 'Correo no válido';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        const SizedBox(height: 20),

                                        // Campo Contraseña mejorado
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: primaryBlue.withOpacity(
                                                  0.1,
                                                ),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: TextFormField(
                                            controller: _passwordController,
                                            obscureText: _obscurePassword,
                                            decoration: InputDecoration(
                                              labelText: 'Contraseña',
                                              labelStyle: TextStyle(
                                                color: primaryBlue,
                                              ),
                                              prefixIcon: Container(
                                                margin: const EdgeInsets.all(
                                                  12,
                                                ),
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: primaryBlue
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Icon(
                                                  Icons.lock_outline,
                                                  color: primaryBlue,
                                                  size: 20,
                                                ),
                                              ),
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  _obscurePassword
                                                      ? Icons
                                                            .visibility_off_outlined
                                                      : Icons
                                                            .visibility_outlined,
                                                  color: primaryBlue,
                                                ),
                                                onPressed: () => setState(
                                                  () => _obscurePassword =
                                                      !_obscurePassword,
                                                ),
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                                borderSide: BorderSide.none,
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                                borderSide: BorderSide.none,
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                                borderSide: BorderSide(
                                                  color: primaryBlue,
                                                  width: 2,
                                                ),
                                              ),
                                              errorBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                                borderSide: const BorderSide(
                                                  color: Colors.red,
                                                ),
                                              ),
                                              filled: true,
                                              fillColor: theme.scaffoldBackgroundColor,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 18,
                                                  ),
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Campo obligatorio';
                                              }
                                              if (value.length < 6) {
                                                return 'Mínimo 6 caracteres';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        const SizedBox(height: 14),

                                        // Botón de login premium
                                        widget.isLoading
                                            ? Container(
                                                padding: const EdgeInsets.all(
                                                  18,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: primaryBlue
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(18),
                                                ),
                                                child: CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(primaryBlue),
                                                  strokeWidth: 3,
                                                ),
                                              )
                                            : Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(18),
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: [
                                                      primaryBlue,
                                                      lightBlue,
                                                    ],
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: primaryBlue
                                                          .withOpacity(0.4),
                                                      blurRadius: 12,
                                                      offset: const Offset(
                                                        0,
                                                        6,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                child: ElevatedButton(
                                                  onPressed: _handleLogin,
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    shadowColor:
                                                        Colors.transparent,
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 20,
                                                        ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            18,
                                                          ),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      const Icon(
                                                        Icons.login_rounded,
                                                        size: 22,
                                                        color: Colors.white,
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Text(
                                                        "Ingresar",
                                                        style:
                                                            GoogleFonts.poppins(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),

                                        const SizedBox(height: 16),

                                        // Divider con texto
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Divider(
                                                color: primaryBlue.withOpacity(
                                                  0.2,
                                                ),
                                                thickness: 1,
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                  ),
                                              child: Text(
                                                "¿Necesitas ayuda?",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  color: primaryBlue
                                                      .withOpacity(0.6),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Divider(
                                                color: primaryBlue.withOpacity(
                                                  0.2,
                                                ),
                                                thickness: 1,
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 20),

                                        // Enlaces adicionales mejorados
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            TextButton.icon(
                                              onPressed: () async {
                                                final urlSupport =
                                                    "https://api.whatsapp.com/send?phone=593963088564&text=Necesito%20soporte";
                                                debugPrint("URL $urlSupport");
                                                if (await canLaunchUrl(
                                                  Uri.parse(urlSupport),
                                                )) {
                                                  await launchUrl(
                                                    Uri.parse(urlSupport),
                                                    mode: LaunchMode
                                                        .platformDefault,
                                                  );
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Abriendo enlace de soporte',
                                                      ),
                                                      backgroundColor:
                                                          Colors.green,
                                                    ),
                                                  );
                                                } else {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Ah ocurrido un error',
                                                      ),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                  );
                                                }
                                              },
                                              icon: Icon(
                                                Icons.help_outline,
                                                size: 16,
                                                color: primaryBlue,
                                              ),
                                              label: Text(
                                                "Soporte",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  color: primaryBlue,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            /* Container(
                                              height: 20,
                                              width: 1,
                                              color: primaryBlue.withOpacity(
                                                0.3,
                                              ),
                                            ), */
                                            /*          TextButton.icon(
                                              onPressed: () {},
                                              icon: Icon(
                                                Icons.lock_reset,
                                                size: 16,
                                                color: primaryBlue,
                                              ),
                                              label: Text(
                                                "Recuperar",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  color: primaryBlue,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ), */
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
