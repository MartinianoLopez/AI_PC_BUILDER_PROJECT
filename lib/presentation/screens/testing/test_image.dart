import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<http.Response> testImage() async {
  try {
    final response = await http
        .get(
          Uri.parse("https://try.com.ar/wp-content/uploads/2023/10/Mother-MSI-A520M-PRO-VH-600x600_20_11zon.webp"),
          headers: {
            "User-Agent": "Mozilla/5.0",
            "Accept": "image/webp,image/apng,image/*,*/*;q=0.8",
          },
        )
        .timeout(const Duration(seconds: 5));

    return response;
  } catch (e) {
    rethrow; // Re-throws the exception for better handling
  }
}

class ImageTesterScreen extends StatefulWidget {
  const ImageTesterScreen({super.key});

  @override
  State<ImageTesterScreen> createState() => _ImageTesterScreenState();
}

class _ImageTesterScreenState extends State<ImageTesterScreen> {
  late Future<http.Response> _imageResponse;

  @override
  void initState() {
    super.initState();
    _imageResponse = testImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Image Test")),
      body: Center(
        child: FutureBuilder<http.Response>(
          future: _imageResponse,
          builder: (BuildContext context, AsyncSnapshot<http.Response> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData && snapshot.data!.statusCode == 200) {
              // Successfully fetched image
              return Image.network(
                "https://try.com.ar/wp-content/uploads/2023/10/Mother-MSI-A520M-PRO-VH-600x600_20_11zon.webp",
                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  } else {
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                      ),
                    );
                  }
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Text('Error loading image');
                },
              );
            } else {
              return const Text('Failed to load image');
            }
          },
        ),
      ),
    );
  }
}
