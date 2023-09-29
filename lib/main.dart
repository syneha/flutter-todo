
import 'package:flutter/material.dart';
 
// function to trigger build when the app is run
void main() {
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => const HomeRoute(),
      '/second': (context) => const SecondRoute(),
      '/third': (context) => const ThirdRoute(),
    },
  )); //MaterialApp
}
 
class HomeRoute extends StatelessWidget {
  const HomeRoute({Key? key}) : super(key: key);
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('First_page'),
        backgroundColor: Colors.red,
      ), // AppBar
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: const Text('Click here'),
              onPressed: () {
                Navigator.pushNamed(context, '/second');
              },
            ), // ElevatedButton
            ElevatedButton(
              child: const Text('Tap here!'),
              onPressed: () {
                Navigator.pushNamed(context, '/third');
              },
            ), // ElevatedButton
          ], // <Widget>[]
        ), // Column
      ), // Center
    ); // Scaffold
  }
}
 
class SecondRoute extends StatelessWidget {
  const SecondRoute({Key? key}) : super(key: key);
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Second_page"),
        backgroundColor: Color.fromARGB(255, 162, 33, 173),
      ), // AppBar
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Back'),
        ), // ElevatedButton
      ), // Center
    ); // Scaffold
  }
}
 
class ThirdRoute extends StatelessWidget {
  const ThirdRoute({Key? key}) : super(key: key);
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Third_page"),
        backgroundColor: Color.fromARGB(255, 192, 135, 11),
      ), // AppBar
    ); // Scaffold
  }
}