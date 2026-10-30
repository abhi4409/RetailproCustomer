import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});
  static const brown = Color(0xFF5C3C2A);
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: brown,
        foregroundColor: Colors.white,
      ),

      body: Container(

        color: const Color(0xFFEDE0D4),
        padding: const EdgeInsets.all(16),

        child: SingleChildScrollView(

          child: Container(

            padding: const EdgeInsets.all(18),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),

              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),

            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(
                  "Privacy Policy",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: brown,
                  ),
                ),

                SizedBox(height: 20),

                Text(
                  "At CupfulCanvas, your privacy is important to us. "
                      "We collect only the information necessary to improve your experience and process your coffee orders.",

                  style: TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: brown,
                  ),
                ),

                SizedBox(height: 16),

                Text(
                  "Information We Collect",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: brown,
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  "• Name and contact details\n"
                      "• Order and payment details\n"
                      "• App usage information",

                  style: TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: brown,
                  ),
                ),

                SizedBox(height: 16),

                Text(
                  "How We Use Information",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: brown,
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  "We use your information to process orders, "
                      "improve our services, and provide a better user experience.",

                  style: TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: brown,
                  ),
                ),

                SizedBox(height: 16),

                Text(
                  "Security",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: brown,
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  "Your personal information is kept secure and is never shared unnecessarily.",

                  style: TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: brown,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class Terms extends StatelessWidget {
  Terms({super.key, this.radius = 8, required this.mdFilename})
      : assert(
  mdFilename.contains('.md'), 'The file must contain .md extension');
  final double radius;
  final String mdFilename;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Column(
        children: [
          Expanded(
              child: FutureBuilder(
                future: Future.delayed(const Duration(microseconds: 150))
                    .then((value) => rootBundle.loadString('lib/view/Privacy/1f91da14-fa4a-4994-9ced-7eb58a02b24d_en.md')),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Markdown(
                        styleSheet: MarkdownStyleSheet.fromTheme(ThemeData(
                            textTheme: const TextTheme(
                                bodyMedium: TextStyle(
                                    fontSize: 15.0, color: Colors.black)))),
                        data: snapshot.data.toString());
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              )),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Container(
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  )),
              alignment: Alignment.center,
              height: 50,
              width: double.infinity,
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }
}