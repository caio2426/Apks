import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';

void main() => runApp(const LegendAIApp());

class LegendAIApp extends StatelessWidget {
  const LegendAIApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D0E15),
        primaryColor: const Color(0xFF6C5CE7),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _isProcessing = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOutCubic),
    );
  }

  Future<void> _pickVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.video);

    if (result != null && result.files.single.path != null) {
      setState(() {
        _isProcessing = true;
      });

      // Simulação do processo de IA e carregamento
      _controller = VideoPlayerController.contentUri(Uri.parse(result.files.single.path!))
        ..initialize().then((_) {
          setState(() {
            _isProcessing = false;
            _controller!.play();
            _controller!.setLooping(true);
            _animationController.forward(from: 0.0);
          });
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fundo com Gradiente Sutil
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0D0E15), Color(0xFF1A1B2F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          
          // Conteúdo Principal
          Center(
            child: _controller != null && _controller!.value.isInitialized
                ? FadeTransition(
                    opacity: _fadeAnimation,
                    child: AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          VideoPlayer(_controller!),
                          // Container das Legendas com Animação Fluida
                          Positioned(
                            bottom: 40,
                            left: 20,
                            right: 20,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.65),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                "Aqui vai a legenda traduzida em tempo real...",
                                textAlign: Center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const WelcomeWidget(),
          ),

          // Overlay de Carregamento Ultra Fluido
          if (_isProcessing)
            Container(
              color: Colors.black85,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    CircularProgressIndicator(color: Color(0xFF6C5CE7)),
                    SizedBox(height: 20),
                    Text(
                      "A inteligência artificial está traduzindo...",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: _controller == null
          ? null
          : FloatingActionButton(
              backgroundColor: const Color(0xFF6C5CE7),
              onPressed: _pickVideo,
              child: const Icon(Icons.video_library),
            ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _animationController.dispose();
    super.dispose();
  }
}

class WelcomeWidget extends StatelessWidget {
  const WelcomeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.closed_caption_rounded, size: 80, color: const Color(0xFF6C5CE7).withOpacity(0.8)),
        const SizedBox(height: 24),
        const Text(
          "Legende qualquer idioma para o Português",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          "Selecione um vídeo e a IA faz o resto.",
          style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.6)),
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C5CE7),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            final state = context.findAncestorStateOfType<_HomeScreenState>();
            state?._pickVideo();
          },
          icon: const Icon(Icons.add_to_queue, color: Colors.white),
          label: const Text("Importar Vídeo", style: TextStyle(fontSize: 16, color: Colors.white)),
        ),
      ],
    );
  }
}

