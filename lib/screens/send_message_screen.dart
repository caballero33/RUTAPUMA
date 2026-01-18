import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class SendMessageScreen extends StatefulWidget {
  const SendMessageScreen({super.key});

  @override
  State<SendMessageScreen> createState() => _SendMessageScreenState();
}

class _SendMessageScreenState extends State<SendMessageScreen> {
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_formKey.currentState!.validate()) {
      // Simulate sending message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Mensaje enviado correctamente',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      Navigator.pop(context); // Go back after sending
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? AppColors.white : AppColors.darkBlue,
            size: 28,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Enviar Mensaje',
          style: TextStyle(
            color: isDark ? AppColors.white : AppColors.darkBlue,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Banner
              Container(
                margin: const EdgeInsets.only(bottom: 30),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? AppColors.darkAccent
                          : AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color:
                        isDark
                            ? AppColors.primaryYellow
                            : AppColors.primaryBlue,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.campaign_rounded,
                      color:
                          isDark
                              ? AppColors.primaryYellow
                              : AppColors.primaryBlue,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Este mensaje se enviará a los usuarios suscritos a tu ruta.',
                        style: TextStyle(
                          color: isDark ? AppColors.white : AppColors.darkBlue,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Subject Field
              CustomTextField(
                label: 'Asunto',
                hint: 'Ej. Retraso por tráfico',
                prefixIcon: Icons.title_rounded,
                controller: _subjectController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El asunto es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Message Field
              // CustomTextField layout but adapted for multiline if needed
              // or just use CustomTextField if it supports it nicely.
              // CustomTextField as implemented has fixed height implicitly via layout but
              // TextInputType.multiline usually helps.
              // Let's us CustomTextField but we might need maxLines or minLines support
              // which our current CustomTextField doesn't explicitly expose for customization
              // aside from keyboardType.
              // For a message body, it's better to have more lines.
              // Since CustomTextField is rigid, I will build a custom layout here for the message area
              // to make it look like a "text area".
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10, bottom: 8),
                    child: Text(
                      'Mensaje',
                      style: TextStyle(
                        color:
                            isDark
                                ? AppColors.white.withOpacity(0.8)
                                : AppColors.darkGrey,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: _messageController,
                    maxLines: 6,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El mensaje es requerido';
                      }
                      return null;
                    },
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.white : AppColors.darkBlue,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Escribe tu mensaje aquí...',
                      hintStyle: TextStyle(
                        color:
                            isDark
                                ? AppColors.white.withOpacity(0.3)
                                : AppColors.grey.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                      filled: true,
                      fillColor:
                          isDark ? AppColors.darkAccent : AppColors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide:
                            isDark
                                ? const BorderSide(
                                  color: AppColors.darkBorder,
                                  width: 1,
                                )
                                : BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(
                          color:
                              isDark
                                  ? AppColors.primaryYellow
                                  : AppColors.primaryBlue,
                          width: 3,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(20),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Send Button
              CustomButton(
                text: 'ENVIAR AVISO',
                onPressed: _sendMessage,
                gradient: isDark ? AppColors.blueGradient : null,
                color: isDark ? null : AppColors.primaryBlue,
                textColor: AppColors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
