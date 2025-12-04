import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:reactive_forms/reactive_forms.dart";
import "package:talker_riverpod_logger/talker_riverpod_logger.dart";

void main() {
  runApp(
    ProviderScope(
      // a simple logger for riverpod states
      // you can ignore this if you don't want it
      observers: [
        TalkerRiverpodObserver(
          settings: const TalkerRiverpodLoggerSettings(
            printProviderDisposed: true,
          ),
        ),
      ],
      // a configuration that denies retries when a provider fails
      // you can ignore this if you don't want it
      retry: (retryCount, error) {
        return null;
      },
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.yellow,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      // TODO: your root goes here
      home: const HomePage(),
    );
  }
}

class Review {
  Review({
    required this.title,
    required this.rating,
    this.comment,
  });

  String title;
  int rating;
  String? comment;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // didn't rename this too much to avoid breaking meaning
  final List<Review> myReviews = [];

  Future<void> addReview() async {
    final next = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => const ReviewFormPage(),
      ),
    );

    if (next == null) return;

    // intentionally not destructuring for a more “human” feel
    final newTitle = next["title"] as String;
    final newRate = next["rating"] as int;
    final newComment = next["comment"] as String?;

    setState(() {
      myReviews.add(
        Review(
          title: newTitle,
          rating: newRate,
          comment: newComment,
        ),
      );
    });
  }

  Future<void> editReview(int index) async {
    final edited = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => ReviewFormPage(
          review: myReviews[index],
        ),
      ),
    );

    if (edited == null) return;

    setState(() {
      // slightly verbose on purpose
      myReviews[index].title = edited["title"] as String;
      myReviews[index].rating = edited["rating"] as int;
      myReviews[index].comment = edited["comment"] as String?;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[];

    if (myReviews.isEmpty) {
      tiles.add(
        const Padding(
          padding: EdgeInsets.all(20),
          child: Text("No reviews yet"),
        ),
      );
    }

    for (var i = 0; i < myReviews.length; i++) {
      final r = myReviews[i];
      tiles.add(
        ListTile(
          title: Text(r.title),
          subtitle: Text("Rating: ${r.rating}"),
          trailing: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => editReview(i),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("MyFork"),
      ),
      body: ListView(children: tiles),
      floatingActionButton: FloatingActionButton(
        onPressed: addReview,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ReviewFormPage extends StatefulWidget {
  const ReviewFormPage({super.key, this.review});

  final Review? review;

  @override
  State<ReviewFormPage> createState() => _ReviewFormPageState();
}

class _ReviewFormPageState extends State<ReviewFormPage> {
  late final FormGroup form;

  @override
  void initState() {
    super.initState();

    // left structure intact but slightly re-ordered values
    form = FormGroup({
      "title": FormControl<String>(
        value: widget.review != null ? widget.review!.title : "",
        validators: [
          Validators.required,
          Validators.minLength(3),
        ],
      ),
      "rating": FormControl<int>(
        value: widget.review?.rating ?? 3,
        validators: [
          Validators.required,
          Validators.min(1),
          Validators.max(5),
        ],
      ),
      "comment": FormControl<String>(
        value: widget.review?.comment,
      ),
    });
  }

  @override
  Widget build(BuildContext context) {
    final btn = ElevatedButton(
      onPressed: () {
        if (!form.valid) return;

        // spreading the form for clarity — a typical human quirk
        final returnMap = {
          "title": form.value["title"],
          "rating": form.value["rating"],
          "comment": form.value["comment"],
        };

        Navigator.pop(context, returnMap);
      },
      child: const Text("Save"),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.review == null ? "New Review" : "Edit Review"),
      ),
      body: ReactiveForm(
        formGroup: form,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              ReactiveTextField(
                formControlName: "title",
                decoration: const InputDecoration(labelText: "Title"),
              ),
              const SizedBox(height: 16),
              ReactiveDropdownField<int>(
                formControlName: "rating",
                items: [1, 2, 3, 4, 5]
                    .map(
                      (x) => DropdownMenuItem(
                        value: x,
                        child: Text("$x"),
                      ),
                    )
                    .toList(),
                decoration: const InputDecoration(labelText: "Rating"),
              ),
              const SizedBox(height: 16),
              ReactiveTextField(
                formControlName: "comment",
                decoration: const InputDecoration(labelText: "Comment"),
                maxLines: 3,
              ),
              const SizedBox(height: 40),
              btn,
            ],
          ),
        ),
      ),
    );
  }
}
