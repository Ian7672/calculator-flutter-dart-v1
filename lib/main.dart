import 'package:flutter/material.dart';
import 'package:expressions/expressions.dart'; // Pastikan untuk menambahkan dependensi ini di pubspec.yaml

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Menyimpan status tema
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kalkulator',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light, // Mengatur tema berdasarkan status
      home: HomeScreen(
        isDarkMode: _isDarkMode,
        onThemeChanged: (value) {
          setState(() {
            _isDarkMode = value; // Mengubah status tema
          });
        },
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  HomeScreen({required this.isDarkMode, required this.onThemeChanged});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _output = "0";
  String _liveResult = ""; // Menyimpan hasil sementara
  List<String> _history = []; // Menyimpan riwayat kalkulasi

  void _buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == "C") {
        _output = "0";
        _liveResult = ""; // Reset live result
      } else if (buttonText == "DEL") {
        if (_output.length > 1) {
          _output = _output.substring(0, _output.length - 1);
        } else {
          _output = "0";
        }
      } else if (buttonText == "=") {
        if (_isValidExpression(_output)) {
          String result = _calculateResult();
          if (_isComplexExpression(_output) && result.isNotEmpty) {
            _history.add("$_output = $result"); // Menyimpan riwayat hanya jika ekspresi kompleks
          }
          _output = result; // Tetap menampilkan hasil (atau kosong jika error)
          _liveResult = ""; // Reset live result setelah menghitung
        } else {
          _liveResult = "Ekspresi tidak valid"; // Tampilkan pesan kesalahan
        }
      } else {
        // Izinkan tanda negatif di depan
        if (_output == "0" && buttonText == "-") {
          _output = "-"; // Ganti "0" dengan "-"
        } else if (_output == "0" && buttonText != "-") {
          // Hapus "0" jika tombol yang ditekan bukan "-"
          _output = buttonText;
        } else if (_isLastCharacterOperator(_output) && _isOperator(buttonText)) {
          // Jika karakter terakhir adalah operator dan tombol yang ditekan juga operator, ganti operator
          _output = _output.substring(0, _output.length - 1) + buttonText;
        } else {
          // Hapus angka nol di depan jika ada
          if (_output.startsWith("0") && _output.length > 1 && buttonText != "." && buttonText != "-") {
            _output = _output.substring(1); // Hapus angka nol di depan
          }
          _output += buttonText;
        }
        _liveResult = _calculateResult(); // Update live result saat mengetik
      }
    });
  }

  bool _isLastCharacterOperator(String output) {
    // Cek apakah karakter terakhir adalah operator
    return output.isNotEmpty && _isOperator(output[output.length - 1]);
  }

  bool _isOperator(String character) {
    // Cek apakah karakter adalah operator
    return character == '+' || character == '-' || character == '*' || character == '/';
  }

  bool _isValidExpression(String expression) {
    // Cek apakah jumlah kurung buka dan tutup seimbang
    int openParentheses = 0;
    int closeParentheses = 0;

    for (int i = 0; i < expression.length; i++) {
      if (expression[i] == '(') {
        openParentheses++;
      } else if (expression[i] == ')') {
        closeParentheses++;
      }
    }

    return openParentheses == closeParentheses; // Kembalikan true jika seimbang
  }

  bool _isComplexExpression(String expression) {
    // Cek apakah ekspresi mengandung lebih dari satu angka dan operator
    final regex = RegExp(r'(\d+(\.\d+)?|\.\d+)([+\-*/](\d+(\.\d+)?|\.\d+))+');
    return regex.hasMatch(expression);
  }

  String _calculateResult() {
    try {
      final expression = Expression.parse(_output);
      final evaluator = const ExpressionEvaluator();
      var result = evaluator.eval(expression, {});
      return result.toString();
    } catch (e) {
      return ""; // Mengembalikan string kosong jika terjadi error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kalkulator'),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoryScreen(history: _history)),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
          ),
          // Switch untuk mengubah mode gelap/terang
          Switch(
            value: widget.isDarkMode,
            onChanged: widget.onThemeChanged,
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            alignment: Alignment.centerRight,
            child: Text(
              _output,
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
          ),
          // Menampilkan live result di bawah output
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            alignment: Alignment.centerRight,
            child: Text(
              _liveResult,
              style: TextStyle(fontSize: 24, color: Colors.grey),
            ),
          ),
          // Menggunakan Expanded untuk membuat tombol memenuhi ruang
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(child: _buildAcrylicButton("7", isNumber: true)),
              Expanded(child: _buildAcrylicButton("8", isNumber: true)),
              Expanded(child: _buildAcrylicButton("9", isNumber: true)),
              Expanded(child: _buildAcrylicButton("/", isOperator: true)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(child: _buildAcrylicButton("4", isNumber: true)),
              Expanded(child: _buildAcrylicButton("5", isNumber: true)),
              Expanded(child: _buildAcrylicButton("6", isNumber: true)),
              Expanded(child: _buildAcrylicButton("*", isOperator: true)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(child: _buildAcrylicButton("1", isNumber: true)),
              Expanded(child: _buildAcrylicButton("2", isNumber: true)),
              Expanded(child: _buildAcrylicButton("3", isNumber: true)),
              Expanded(child: _buildAcrylicButton("-", isOperator: true)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(child: _buildAcrylicButton("C", isNumber: true)),
              Expanded(child: _buildAcrylicButton("0", isNumber: true)),
              Expanded(child: _buildAcrylicButton(".", isDot: true)), // Tombol titik
              Expanded(child: _buildAcrylicButton("+", isOperator: true)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(child: _buildAcrylicButton("(", isParenthesis: true)), // Tombol kurung buka
              Expanded(child: _buildAcrylicButton(")", isParenthesis: true)), // Tombol kurung tutup
              Expanded(
                child: _buildAcrylicButton(
                  "", 
                  icon: Icons.backspace, // Menggunakan ikon backspace
                ),
              ),
              Expanded(child: _buildAcrylicButton("=", isOperator: true, isEqual: true)), // Tombol sama dengan
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAcrylicButton(String buttonText, {bool isOperator = false, bool isNumber = false, bool isEqual = false, bool isDot = false, bool isParenthesis = false, IconData? icon}) {
    Color buttonColor;

    // Menentukan warna tombol berdasarkan mode dan jenis tombol
    if (isNumber || isDot || isParenthesis) {
      buttonColor = widget.isDarkMode ? Colors.white.withOpacity(0.2) : Colors.black; // Warna tombol angka, titik, dan kurung
    } else if (isEqual) {
      buttonColor = Colors.green; // Warna tombol sama dengan
    } else if (isOperator) {
      buttonColor = Colors.blueAccent.withOpacity(0.8); // Warna tombol operator
    } else {
      buttonColor = (Colors.grey[300] ?? Colors.grey); // Warna default
    }

    return Container(
      margin: EdgeInsets.all(5), // Menambahkan margin di sekitar tombol
      decoration: BoxDecoration(
        color: buttonColor, // Menggunakan warna yang ditentukan
        borderRadius: BorderRadius.circular(10), // Sudut membulat
      ),
      child: ElevatedButton(
        onPressed: () => _buttonPressed(buttonText.isEmpty ? "DEL" : buttonText), // Menggunakan "DEL" jika tombol kosong
        child: icon != null 
            ? Icon(icon, size: 24, color: Colors.black) // Menampilkan ikon backspace
            : Text(
                buttonText,
                style: TextStyle(fontSize: 24, color: Colors.white), // Warna teks
              ),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 20),
          backgroundColor: Colors.transparent, // Menggunakan transparan untuk efek akrilik
          shadowColor: Colors.transparent, // Menghilangkan bayangan default
        ),
      ),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  final List<String> history;

  HistoryScreen({required this.history});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Kalkulasi'),
      ),
      body: ListView.separated(
        itemCount: history.length,
        itemBuilder: (context, index) {
          final entry = history[index].split(" = ");
          return ListTile(
            title: Text(entry[0], style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(entry.length > 1 ? entry[1] : ''),
          );
        },
        separatorBuilder: (context, index) => Divider(), // Menambahkan pemisah
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil Pengguna'),
      ),
      body: Center(
        child: Card(
          elevation: 4, // Menambahkan efek bayangan
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Sudut membulat
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0), // Padding di dalam card
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/user.png'),
                ),
                SizedBox(height: 20),
                Text('Nama: Ian', style: TextStyle(fontSize: 24)),
                SizedBox(height: 20),
                Text('Github: github.com/Ian7672', style: TextStyle(fontSize: 24)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}