import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:finkost/firebase_options.dart';
import 'package:finkost/app.dart';
import 'package:finkost/models/transaction_local_schema.dart';
import 'package:finkost/features/authentication/data/repositories/auth_repository.dart';
import 'package:finkost/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:finkost/features/authentication/presentation/bloc/auth_event.dart';

late Isar isar;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id_ID', null);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final dir = await getApplicationDocumentsDirectory();
  isar = await Isar.open(
    [TransactionLocalSchemaSchema],
    directory: dir.path,
  );

  final prefs = await SharedPreferences.getInstance();
  final bool seenWelcomeScreen = prefs.getBool('seenWelcomeScreen') ?? false;

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            authRepository: AuthRepository(
              firebaseAuth: FirebaseAuth.instance,
              firestore: FirebaseFirestore.instance,
            ),
          )..add(AppStarted()),
        ),
        // TODO: Tambahkan BlocProvider lain seperti TransactionBloc di sini
      ],
      child: MyApp(seenWelcomeScreen: seenWelcomeScreen),
    ),
  );
}