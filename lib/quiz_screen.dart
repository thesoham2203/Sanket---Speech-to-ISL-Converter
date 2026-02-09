import 'package:flutter/material.dart';
import 'dart:math';

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with SingleTickerProviderStateMixin {
  int score = 0;
  int currentQuestion = 0;
  int totalQuestions = 10;
  String currentWord = '';
  List<String> options = [];
  bool answered = false;
  String selectedAnswer = '';
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<Map<String, String>> availableWords = [
    {'word': 'hello', 'duration': '2640'},
    {'word': 'you', 'duration': '3200'},
    {'word': 'good', 'duration': '2640'},
    {'word': 'morning', 'duration': '3080'},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    generateQuestion();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void generateQuestion() {
    answered = false;
    selectedAnswer = '';

    // Pick random word
    final random = Random();
    currentWord = availableWords[random.nextInt(availableWords.length)]['word']!;

    // Generate options
    options = [currentWord];
    List<String> otherWords = availableWords
        .map((w) => w['word']!)
        .where((w) => w != currentWord)
        .toList();

    while (options.length < 4 && otherWords.isNotEmpty) {
      String word = otherWords[random.nextInt(otherWords.length)];
      if (!options.contains(word)) {
        options.add(word);
        otherWords.remove(word);
      }
    }

    // Add dummy options if needed
    List<String> dummyWords = ['please', 'thank', 'sorry', 'help', 'yes', 'no'];
    while (options.length < 4) {
      String word = dummyWords[random.nextInt(dummyWords.length)];
      if (!options.contains(word)) {
        options.add(word);
      }
    }

    options.shuffle();
    _animationController.forward(from: 0.0);
    setState(() {});
  }

  void checkAnswer(String selected) {
    if (answered) return;

    setState(() {
      answered = true;
      selectedAnswer = selected;
      if (selected == currentWord) {
        score++;
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      currentQuestion++;
      if (currentQuestion < totalQuestions) {
        generateQuestion();
      } else {
        showFinalScore();
      }
    });
  }

  void showFinalScore() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              score >= 7 ? Icons.emoji_events : Icons.thumb_up,
              color: Colors.orange,
              size: 32,
            ),
            const SizedBox(width: 10),
            const Text('Quiz Complete!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$score / $totalQuestions',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              score >= 7
                  ? 'Excellent! 🎉'
                  : score >= 5
                      ? 'Good Job! 👍'
                      : 'Keep Practicing! 💪',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Exit'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                score = 0;
                currentQuestion = 0;
                generateQuestion();
              });
            },
            child: const Text('Play Again', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'ISL Quiz',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Score: $score',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            Container(
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: currentQuestion / totalQuestions,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${currentQuestion + 1}/$totalQuestions',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(Icons.lightbulb_outline, color: Colors.grey[600]),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // GIF Display with animation
            Expanded(
              flex: 3,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/ISL_Gifs/$currentWord.gif',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'What sign is this?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // Answer options
            Expanded(
              flex: 2,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: options.length,
                itemBuilder: (context, index) {
                  String option = options[index];
                  bool isSelected = selectedAnswer == option;
                  bool isCorrect = option == currentWord;

                  Color getColor() {
                    if (!answered) return Colors.white;
                    if (isSelected) {
                      return isCorrect ? Colors.green[100]! : Colors.red[100]!;
                    }
                    if (isCorrect) return Colors.green[100]!;
                    return Colors.white;
                  }

                  IconData? getIcon() {
                    if (!answered) return null;
                    if (isSelected) {
                      return isCorrect ? Icons.check_circle : Icons.cancel;
                    }
                    if (isCorrect) return Icons.check_circle;
                    return null;
                  }

                  Color? getIconColor() {
                    if (!answered) return null;
                    if (isSelected) {
                      return isCorrect ? Colors.green : Colors.red;
                    }
                    if (isCorrect) return Colors.green;
                    return null;
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: getColor(),
                      borderRadius: BorderRadius.circular(15),
                      elevation: answered && isSelected ? 0 : 2,
                      child: InkWell(
                        onTap: () => checkAnswer(option),
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: answered && (isSelected || isCorrect)
                                  ? (isCorrect ? Colors.green : Colors.red)
                                  : Colors.grey[300]!,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.orange[100],
                                ),
                                child: Center(
                                  child: Text(
                                    String.fromCharCode(65 + index), // A, B, C, D
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Text(
                                  option.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (getIcon() != null)
                                Icon(
                                  getIcon(),
                                  color: getIconColor(),
                                  size: 28,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

