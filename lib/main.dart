import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Movie Model
class Movie {
  final String title;
  final String year;
  final String imdbId;
  final String poster;


  Movie({
    required this.title,
    required this.year,
    required this.imdbId,
    required this.poster,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['Title'],
      year: json['Year'],
      imdbId: json['imdbID'],
      poster: json['Poster'],
    );
  }
}

// Movie Details Screen
class MovieDetailScreen extends StatelessWidget {
  final String imdbId;

  MovieDetailScreen({required this.imdbId});

  Future<Map<String, dynamic>> fetchMovieDetails() async {
    final apiKey = 'd044ef44';
    final response = await http.get(Uri.parse('https://www.omdbapi.com/?i=$imdbId&apikey=$apiKey'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load movie details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Movie Details')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchMovieDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            var data = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row( children: [
                  Column(
                    children: [
                      Image.network(data['Poster']),
                      SizedBox(height: 16)]),
                  Column(
                    children: [
                    Text('Title: ${data['Title']}', style: TextStyle(fontSize: 22)),
                    SizedBox(height: 8),
                    Text('Year: ${data['Year']}', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 8),
                    Text('Genres: ${data['Genre']}', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 8),
                    Text('Director: ${data['Director']}', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 8),
                    Text('Writers: ${data['Writer']}', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 8),
                    Text('Actors: ${data['Actors']}', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 8),
                    Text('Plot: ${data['Plot']}', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 8),
                    Text('Awards: ${data['Awards']}', style: TextStyle(fontSize: 18))
              ])],
            ));
          } else {
            return Center(child: Text('No data found.'));
          }
        },
      ),
    );
  }
}

// Movie Search Screen
class MovieSearchScreen extends StatefulWidget {
  @override
  _MovieSearchScreenState createState() => _MovieSearchScreenState();
}

class _MovieSearchScreenState extends State<MovieSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Movie> _movies = [];
  bool _isLoading = false;

  Future<void> searchMovies(String query) async {
    final apiKey = 'd044ef44';
    setState(() {
      _isLoading = true;
    });

    final response = await http.get(Uri.parse('https://www.omdbapi.com/?s=$query&apikey=$apiKey'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['Response'] == 'True') {
        setState(() {
          _movies = (data['Search'] as List)
              .map((movieJson) => Movie.fromJson(movieJson))
              .toList();
        });
      } else {
        setState(() {
          _movies = [];
        });
      }
    } else {
      throw Exception('Failed to load movies');
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Movie Search')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Movies',
                border: OutlineInputBorder(),
              ),
              onSubmitted: searchMovies,
            ),
            SizedBox(height: 16),
            _isLoading
                ? CircularProgressIndicator()
                : Expanded(
              child: ListView.builder(
                itemCount: _movies.length,
                itemBuilder: (context, index) {
                  final movie = _movies[index];
                  return ListTile(
                    leading: movie.poster != 'N/A'
                        ? Image.network(movie.poster)
                        : Icon(Icons.movie),
                    title: Text(movie.title),
                    subtitle: Text(movie.year),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MovieDetailScreen(imdbId: movie.imdbId),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MovieSearchScreen(),
  ));
}
