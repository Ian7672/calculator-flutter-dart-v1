import 'package:flutter/material.dart';
import 'package:expressions/expressions.dart'; // Pastikan untuk menambahkan dependensi ini di pubspec.yaml
import 'package:flutter/services.dart'; // Impor untuk Clipboard

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  // Menyimpan status tema
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kalkulator',
      debugShowCheckedModeBanner: false,
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

  const HomeScreen({super.key, required this.isDarkMode, required this.onThemeChanged});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  String _output = "0";
  String _liveResult = ""; // Menyimpan hasil sementara
  final List<String> _history = []; // Menyimpan riwayat kalkulasi

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
        _liveResult = _calculateResult();

      } else if (buttonText == "=") {
        if (_isValidExpression(_output)) {
          String result = _calculateResult();
          if (_isComplexExpression(_output) && result.isNotEmpty) {
            _history.add("$_output = $result"); // Menyimpan riwayat hanya jika ekspresi kompleks
          }
          _output = result; // Tetap menampilkan hasil (atau kosong jika error)
          _liveResult = ""; // Reset live result setelah menghitung
        } else {
          _liveResult = ""; // Tidak menampilkan pesan kesalahan
        }
      } else {
        // Izinkan tanda negatif di depan
        if (_output == "0" && buttonText == "-") {
          _output = "-"; // Ganti "0" dengan "-"
        } else if (_output == "0" && (buttonText == "+" || buttonText == "/" || buttonText == "*")) {
          // jika tombol yang ditekan bukan "-"
          return; // Tidak melakukan apa-apa
        } else if (_output == "-" && (buttonText == "+" || buttonText == "/" || buttonText == "*" || buttonText == ".")) {
          // Jika output hanya berisi "-", tidak izinkan operator lain
          if (_isOperator(buttonText)) {
            return; // Tidak melakukan apa-apa
          }
        } else if (_isLastCharacterOperator(_output) && _isOperator(buttonText)) {
          // Jika karakter terakhir adalah operator dan tombol yang ditekan juga operator, tidak melakukan apa-apa
          return; // Tidak melakukan apa-apa
        } else if (_isLastCharacterOperator(")") && buttonText == "(") {
          return; // Tidak melakukan apa-apa
          } else if (_isLastCharacterOperator(".") && _isOperator(buttonText)) {
          return; // Tidak melakukan apa-apa
        } else if (buttonText == ".") {
          // Cek jika titik sudah ada dalam angka terakhir
          if (!_output.endsWith(".") && !_isLastCharacterOperator(_output)) {
            String lastNumber = _getLastNumber(_output);
            if (!lastNumber.contains(".")) {
              _output += buttonText;
            }
          }
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

  String _getLastNumber(String expression) {
    // Mengambil angka terakhir dari ekspresi
    final regex = RegExp(r'(\d+(\.\d+)?)$');
    final match = regex.firstMatch(expression);
    return match != null ? match.group(0) ?? "" : "";
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

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Teks disalin: $text')),
    );
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
          Expanded(
            child: SingleChildScrollView(
              reverse: true, // Agar scroll ke atas
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      _copyToClipboard(_output); // Menyalin teks saat diketuk
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                      alignment: Alignment.centerRight,
                      child: Text(
                        _output,
                        style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                      ),
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
                ],
              ),
            ),
          ),
          SizedBox(height: 20), // Menambahkan jarak antara layar dan tombol
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
      buttonColor = widget.isDarkMode 
    ? Colors.white.withAlpha((0.2 * 255).toInt()) 
    : Colors.black; // Warna tombol angka, titik, dan kurung
    } else if (isEqual) {
      buttonColor = Colors.green; // Warna tombol sama dengan
    } else if (isOperator) {
      buttonColor = Colors.blueAccent.withAlpha((0.8 * 255).toInt()); // Warna tombol operator
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
              style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 20),
          backgroundColor: Colors.transparent, // Menggunakan transparan untuk efek akrilik
          shadowColor: Colors.transparent, // Menghilangkan bayangan default
        ),
        child: icon != null 
            ? Icon(icon, size: 24, color: Colors.black) // Menampilkan ikon backspace
            : Text(
                buttonText,
                style: TextStyle(fontSize: 24, color: Colors.white), // Warna teks
              ),

      ),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  final List<String> history;

  const HistoryScreen({super.key, required this.history});

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
  const ProfileScreen({super.key});
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