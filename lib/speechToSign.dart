import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:sanket/utils.dart' as utils;
import 'package:translator/translator.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'history_manager.dart';
import 'history_screen.dart';
import 'quiz_screen.dart';

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

  bool _isListening = false;
  bool _isTranslating = false;
  String _text = '';
  String _originalText = '';
  String _img = 'space';
  String _ext = '.png';
  String _path = 'assets/letters/';
  String _displaytext = 'Tap the mic and start speaking...';
  int _state = 0;
  double _displaySpeed = 1.0;
  String _selectedLanguage = 'en';

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.orange,
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
                      color: Colors.white,
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
                        const Icon(Icons.language, color: Colors.orange),
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
                              icon: const Icon(Icons.arrow_drop_down, color: Colors.orange),
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

                  // Sign image display with beautiful container
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.1),
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
                        colors: [Colors.orange[50]!, Colors.orange[100]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.orange[200]!, width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.text_fields, color: Colors.orange[700], size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Translation:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[700],
                              ),
                            ),
                            const Spacer(),
                            if (_displaytext.isNotEmpty &&
                                _displaytext != 'Tap the mic and start speaking...')
                              IconButton(
                                icon: const Icon(Icons.volume_up, color: Colors.orange),
                                iconSize: 20,
                                onPressed: () => _tts.speak(_text),
                                tooltip: 'Speak',
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
                      color: Colors.white,
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
                                color: Colors.orange[100],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${_displaySpeed.toStringAsFixed(1)}x',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
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
                                activeColor: Colors.orange,
                                inactiveColor: Colors.orange[100],
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
        glowColor: Colors.orange,
        endRadius: 80.0,
        duration: const Duration(milliseconds: 2000),
        repeatPauseDuration: const Duration(milliseconds: 100),
        repeat: true,
        child: FloatingActionButton.large(
          onPressed: _listen,
          backgroundColor: _isListening ? Colors.red : Colors.orange,
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

