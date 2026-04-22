import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:sanket/utils.dart' as utils;
import 'package:translator/translator.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import 'history_manager.dart';
import 'history_screen.dart';
import 'quiz_screen.dart';
import 'settings_screen.dart';
import 'ocr_service.dart';
import 'autocomplete_service.dart';
import 'theme_manager.dart';

class SpeechScreen extends StatefulWidget {
  const SpeechScreen({Key? key}) : super(key: key);

  @override
  State<SpeechScreen> createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> with TickerProviderStateMixin {
  late stt.SpeechToText _speech;
  late GoogleTranslator _translator;
  late FlutterTts _tts;
  late AnimationController _imageAnimationController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  final OCRService _ocrService = OCRService();
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();

  bool _isListening = false;
  bool _isTranslating = false;
  bool _showTextInput = false;
  String _text = '';
  String _originalText = '';
  String _img = 'space';
  String _ext = '.png';
  String _path = 'assets/letters/';
  String _displaytext = 'Tap the mic and start speaking...';
  int _state = 0;
  double _displaySpeed = 1.0;
  String _selectedLanguage = 'en';
  List<String> _suggestions = [];

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English', 'flag': '🇬🇧'},
    {'code': 'hi', 'name': 'हिंदी', 'flag': '🇮🇳'},
    {'code': 'mr', 'name': 'मराठी', 'flag': '🇮🇳'},
    {'code': 'ta', 'name': 'தமிழ்', 'flag': '🇮🇳'},
    {'code': 'te', 'name': 'తెలుగు', 'flag': '🇮🇳'},
    {'code': 'gu', 'name': 'ગુજરાતી', 'flag': '🇮🇳'},
    {'code': 'bn', 'name': 'বাংলা', 'flag': '🇮🇳'},
  ];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _translator = GoogleTranslator();
    _tts = FlutterTts();
    _initTTS();
    _loadSavedLanguage();

    _imageAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _imageAnimationController, curve: Curves.easeInOut),
    );

    _imageAnimationController.forward();
  }

  void _initTTS() async {
    await _tts.setLanguage('en-IN');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  void _loadSavedLanguage() async {
    String lang = await HistoryManager.getLanguage();
    setState(() {
      _selectedLanguage = lang;
    });
  }

  @override
  void dispose() {
    _imageAnimationController.dispose();
    _pulseController.dispose();
    _tts.stop();
    _textController.dispose();
    _textFocusNode.dispose();
    _ocrService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final isDark = themeManager.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: themeManager.accentColor,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              "assets/logo/sanket_icon.png",
              height: 32,
              width: 32,
            ),
            const SizedBox(width: 10),
            const Text(
              'Sanket',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            tooltip: 'History',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
              if (result != null) {
                setState(() {
                  _text = result;
                  _originalText = result;
                });
                translation(_text);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.quiz, color: Colors.white),
            tooltip: 'Quiz',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QuizScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main content
          RefreshIndicator(
            onRefresh: _resetTranslation,
            color: Colors.orange,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Language selector
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.language, color: themeManager.accentColor),
                        const SizedBox(width: 10),
                        const Text(
                          'Speak in:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedLanguage,
                              isExpanded: true,
                              icon: Icon(Icons.arrow_drop_down, color: themeManager.accentColor),
                              items: _languages.map((lang) {
                                return DropdownMenuItem(
                                  value: lang['code'],
                                  child: Row(
                                    children: [
                                      Text(
                                        lang['flag']!,
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        lang['name']!,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => _selectedLanguage = value!);
                                HistoryManager.saveLanguage(value!);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Multi-Modal Input Buttons
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Input Methods',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildInputMethodButton(
                              icon: Icons.text_fields,
                              label: 'Text',
                              onTap: () {
                                setState(() {
                                  _showTextInput = !_showTextInput;
                                  if (_showTextInput) {
                                    _textFocusNode.requestFocus();
                                  }
                                });
                              },
                              color: themeManager.accentColor,
                            ),
                            _buildInputMethodButton(
                              icon: Icons.camera_alt,
                              label: 'Camera',
                              onTap: _pickImageFromCamera,
                              color: themeManager.accentColor,
                            ),
                            _buildInputMethodButton(
                              icon: Icons.photo_library,
                              label: 'Gallery',
                              onTap: _pickImageFromGallery,
                              color: themeManager.accentColor,
                            ),
                            _buildInputMethodButton(
                              icon: Icons.content_paste,
                              label: 'Paste',
                              onTap: _pasteFromClipboard,
                              color: themeManager.accentColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Text Input Field with Autocomplete
                  if (_showTextInput)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TypeAheadField<String>(
                            controller: _textController,
                            focusNode: _textFocusNode,
                            builder: (context, controller, focusNode) {
                              return TextField(
                                controller: controller,
                                focusNode: focusNode,
                                decoration: InputDecoration(
                                  hintText: 'Type text here...',
                                  prefixIcon: Icon(Icons.edit, color: themeManager.accentColor),
                                  suffixIcon: controller.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear),
                                          onPressed: () {
                                            controller.clear();
                                            setState(() {});
                                          },
                                        )
                                      : null,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: themeManager.accentColor),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: themeManager.accentColor, width: 2),
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {});
                                },
                              );
                            },
                            suggestionsCallback: (pattern) async {
                              return AutocompleteService.getSuggestions(pattern);
                            },
                            itemBuilder: (context, String suggestion) {
                              return ListTile(
                                leading: Icon(Icons.text_fields, color: themeManager.accentColor, size: 20),
                                title: Text(suggestion),
                              );
                            },
                            onSelected: (String suggestion) {
                              final words = _textController.text.split(' ');
                              if (words.isNotEmpty) {
                                words[words.length - 1] = suggestion;
                                _textController.text = words.join(' ') + ' ';
                                _textController.selection = TextSelection.fromPosition(
                                  TextPosition(offset: _textController.text.length),
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _textController.text.isEmpty ? null : _translateTextInput,
                            icon: const Icon(Icons.translate, color: Colors.white),
                            label: const Text('Translate to ISL', style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeManager.accentColor,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_showTextInput) const SizedBox(height: 16),

                  // Sign image display with beautiful container
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: themeManager.accentColor.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: AspectRatio(
                        aspectRatio: 4 / 3,
                        child: Stack(
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (Widget child, Animation<double> animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: ScaleTransition(
                                    scale: animation,
                                    child: child,
                                  ),
                                );
                              },
                              child: Image.asset(
                                '$_path$_img$_ext',
                                key: ValueKey<int>(_state),
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Icon(
                                      Icons.sign_language,
                                      size: 100,
                                      color: Colors.grey[300],
                                    ),
                                  );
                                },
                              ),
                            ),
                            if (_isTranslating)
                              Container(
                                color: Colors.black.withOpacity(0.3),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Text display area
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF2A2A2A), const Color(0xFF1E1E1E)]
                            : [themeManager.accentColor.withOpacity(0.1), themeManager.accentColor.withOpacity(0.2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: themeManager.accentColor.withOpacity(0.3), width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.text_fields, color: themeManager.accentColor, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Translation:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: themeManager.accentColor,
                              ),
                            ),
                            const Spacer(),
                            if (_displaytext.isNotEmpty &&
                                _displaytext != 'Tap the mic and start speaking...')
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.volume_up, color: themeManager.accentColor),
                                    iconSize: 20,
                                    onPressed: () => _tts.speak(_text),
                                    tooltip: 'Speak',
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.share, color: themeManager.accentColor),
                                    iconSize: 20,
                                    onPressed: _shareTranslation,
                                    tooltip: 'Share',
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(
                            _displaytext,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (_originalText.isNotEmpty && _originalText != _text)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              const Divider(),
                              const SizedBox(height: 5),
                              Text(
                                'Original: $_originalText',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Speed control
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Sign Speed',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: themeManager.accentColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${_displaySpeed.toStringAsFixed(1)}x',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: themeManager.accentColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.slow_motion_video, color: Colors.grey),
                            Expanded(
                              child: Slider(
                                value: _displaySpeed,
                                min: 0.5,
                                max: 2.0,
                                divisions: 6,
                                activeColor: themeManager.accentColor,
                                inactiveColor: themeManager.accentColor.withOpacity(0.3),
                                onChanged: (value) {
                                  setState(() => _displaySpeed = value);
                                },
                              ),
                            ),
                            const Icon(Icons.fast_forward, color: Colors.grey),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 120), // Space for FAB
                ],
              ),
            ),
          ),

          // Listening indicator
          if (_isListening)
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_pulseController.value * 0.1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.mic, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Listening...',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: _isListening,
        glowColor: themeManager.accentColor,
        endRadius: 80.0,
        duration: const Duration(milliseconds: 2000),
        repeatPauseDuration: const Duration(milliseconds: 100),
        repeat: true,
        child: FloatingActionButton.large(
          onPressed: _listen,
          backgroundColor: _isListening ? Colors.red : themeManager.accentColor,
          elevation: 8,
          child: Icon(
            _isListening ? Icons.mic : Icons.mic_none,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }

  Future<void> _resetTranslation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _text = '';
      _originalText = '';
      _path = 'assets/letters/';
      _img = 'space';
      _ext = '.png';
      _displaytext = 'Tap the mic and start speaking...';
      _state = 0;
      _isTranslating = false;
    });
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
        debugLogging: false,
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          localeId: _selectedLanguage == 'en' ? 'en-US' : '$_selectedLanguage-IN',
          onResult: (val) async {
            String recognizedText = val.recognizedWords;

            // If not English, translate to English
            if (_selectedLanguage != 'en') {
              try {
                var translationResult = await _translator.translate(
                  recognizedText,
                  from: _selectedLanguage,
                  to: 'en',
                );
                setState(() {
                  _originalText = recognizedText;
                  _text = translationResult.text;
                  _displaytext = translationResult.text;
                });
              } catch (e) {
                print('Translation error: $e');
                setState(() {
                  _text = recognizedText;
                  _originalText = recognizedText;
                  _displaytext = recognizedText;
                });
              }
            } else {
              setState(() {
                _text = recognizedText;
                _originalText = recognizedText;
                _displaytext = recognizedText;
              });
            }
          },
        );
      }
    } else {
      setState(() {
        _isListening = false;
        _isTranslating = true;
      });
      _speech.stop();

      // Save to history
      if (_text.isNotEmpty) {
        await HistoryManager.saveTranslation(_text);
      }

      await translation(_text);

      setState(() {
        _isTranslating = false;
      });
      _state = 0;
    }
  }

  Future<void> translation(String _text) async {

    _displaytext = '';
    String speechStr = _text.toLowerCase();

    // -------- logic - detect phrases --------------------
    // List<String> subList = [];
    // List<String> strArray = filterKnownStr(speechStr, utils.phrases, subList);
    // -------- end logic - detect phrases ----------------

    // if(utils.phrases.contains(speechStr)){
    //   String file = speechStr;
    //   setState(() {
    //     _display_text += _text;
    //     _path = 'assets/ISL_Gifs/';
    //     _img = file;
    //     _ext = '.gif';
    //   });
    //   await Future.delayed(const Duration(milliseconds: 11000));
    //   // return false;
    // } else {
      List<String> strArray = speechStr.split(" ");
    for (String content in strArray) {
      // print('$content');
      // if(utils.phrases.contains(content)){
      //   String file = content;
      //   int idx = utils.phrases.indexOf(content);
      //   int _duration = int.parse(utils.phrases.elementAt(idx+1));
      //   // print('$_duration');
      //   setState(() {
      //     _state += 1;
      //     _displaytext += content;
      //     _path = 'assets/ISL_Gifs/';
      //     _img = file;
      //     _ext = '.gif';
      //   });
      //   await Future.delayed(Duration(milliseconds: _duration));
      //
      // } else
        if (utils.words.contains(content)){
        String file = content;
        int idx = utils.words.indexOf(content);
        int _duration = int.parse(utils.words.elementAt(idx+1));
        // print('$_duration');
        setState(() {
          _state += 1;
          _displaytext += content;
          _path = 'assets/ISL_Gifs/';
          _img = file;
          _ext = '.gif';
        });
        await Future.delayed(Duration(milliseconds: (_duration / _displaySpeed).round()));
      } else {
        String file = content;
        if(utils.hello.contains(file)){
          file = 'hello';
          int idx = utils.words.indexOf(file);
          int _duration = int.parse(utils.words.elementAt(idx+1));
          // print('$_duration');
          setState(() {
            _state += 1;
            _displaytext += content;
            _path = 'assets/ISL_Gifs/';
            _img = file;
            _ext = '.gif';
          });
          await Future.delayed(Duration(milliseconds: (_duration / _displaySpeed).round()));

        } else if(utils.you.contains(file)) {
          file = 'you';
          int idx = utils.words.indexOf(file);
          int _duration = int.parse(utils.words.elementAt(idx+1));
          // print('$_duration');
          setState(() {
            _state += 1;
            _displaytext += content;
            _path = 'assets/ISL_Gifs/';
            _img = file;
            _ext = '.gif';
          });
          await Future.delayed(Duration(milliseconds: (_duration / _displaySpeed).round()));
        }
        else {
          for (var i = 0; i < content.length; i++){
            if (utils.letters.contains(content[i])) {
              String char = content[i];
              // print('$alphabet');
              setState(() {
                _state += 1;
                _displaytext += char;
                _path = 'assets/letters/';
                _img = char;
                _ext = '.png';
              });
              await Future.delayed(Duration(milliseconds: (1500 / _displaySpeed).round()));

            } else {
              String letter = content[i];
              // print('$letter');
              setState(() {
                _state += 1;
                _displaytext += letter;
                _path = 'assets/letters/';
                _img = 'space';
                _ext = '.png';
              });
              await Future.delayed(Duration(milliseconds: (1000 / _displaySpeed).round()));

            }
          }
        }
      }
      // _display_text += ' ';
      setState(() {
        _state += 1;
        _displaytext += " ";
        _path = 'assets/letters/';
        _img = 'space';
        _ext = '.png';
      });
      await Future.delayed(Duration(milliseconds: (1000 / _displaySpeed).round()));
    }
  }

  // New helper method for input method buttons
  Widget _buildInputMethodButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // OCR from camera
  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() => _isTranslating = true);

        String extractedText = await _ocrService.extractTextFromImage(image.path);

        if (extractedText.isNotEmpty) {
          _textController.text = extractedText;
          setState(() => _isTranslating = false);
          _showSnackBar('Text extracted successfully!', Colors.green);
        } else {
          setState(() => _isTranslating = false);
          _showSnackBar('No text found in image', Colors.orange);
        }
      }
    } catch (e) {
      setState(() => _isTranslating = false);
      _showSnackBar('Error: ${e.toString()}', Colors.red);
    }
  }

  // OCR from gallery
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() => _isTranslating = true);

        String extractedText = await _ocrService.extractTextFromImage(image.path);

        if (extractedText.isNotEmpty) {
          _textController.text = extractedText;
          setState(() => _isTranslating = false);
          _showSnackBar('Text extracted successfully!', Colors.green);
        } else {
          setState(() => _isTranslating = false);
          _showSnackBar('No text found in image', Colors.orange);
        }
      }
    } catch (e) {
      setState(() => _isTranslating = false);
      _showSnackBar('Error: ${e.toString()}', Colors.red);
    }
  }

  // Paste from clipboard
  Future<void> _pasteFromClipboard() async {
    try {
      ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);

      if (data != null && data.text != null && data.text!.isNotEmpty) {
        _textController.text = data.text!;
        setState(() {
          _showTextInput = true;
        });
        _showSnackBar('Text pasted successfully!', Colors.green);
      } else {
        _showSnackBar('Clipboard is empty', Colors.orange);
      }
    } catch (e) {
      _showSnackBar('Error pasting from clipboard', Colors.red);
    }
  }

  // Translate text input
  Future<void> _translateTextInput() async {
    String inputText = _textController.text.trim();

    if (inputText.isEmpty) return;

    setState(() {
      _isTranslating = true;
      _text = inputText;
      _originalText = inputText;
    });

    // Save to history
    await HistoryManager.saveTranslation(inputText);

    // Translate if needed
    if (_selectedLanguage != 'en') {
      try {
        var translationResult = await _translator.translate(
          inputText,
          from: _selectedLanguage,
          to: 'en',
        );
        setState(() {
          _text = translationResult.text;
          _originalText = inputText;
        });
      } catch (e) {
        print('Translation error: $e');
      }
    }

    // Perform translation
    await translation(_text);

    setState(() {
      _isTranslating = false;
      _showTextInput = false;
    });

    // Hide keyboard
    _textFocusNode.unfocus();
  }

  // Share translation
  Future<void> _shareTranslation() async {
    if (_text.isNotEmpty) {
      try {
        await Clipboard.setData(ClipboardData(text: _text));
        _showSnackBar('Copied to clipboard!', Colors.green);
      } catch (e) {
        _showSnackBar('Error sharing text', Colors.red);
      }
    }
  }

  // Show snackbar helper
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

}

List<String> filterKnownStr(String speechStr, List<String> islGif, List<String> finalArr) {

  bool check = true;

  for (String known in islGif) {
    List<String> tmp;
    if (speechStr.contains(known)){
      check = false;
      tmp = speechStr.split(known);
      tmp[0] = tmp[0].trim();
      finalArr.addAll(tmp[0].split(' '));
      finalArr.add(known);

      if (finalArr.isEmpty){
        finalArr =  ['null'];
      }
      if (tmp.length == 1) {
        return finalArr;
      }
      tmp[1] = tmp[1].trim();
      if (tmp[1] != ''){
        return filterKnownStr(tmp[1], islGif, finalArr);
      } else{
        return finalArr;
      }
    }
  }
  if (check) {
    List<String> tmp = speechStr.split(" ");
    finalArr.addAll(tmp);
    return finalArr;
  }
  return [];
}

