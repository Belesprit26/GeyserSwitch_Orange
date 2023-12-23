import 'package:gs_orange/core/common/views/page_under_construction.dart';
import 'package:gs_orange/core/extensions/context_extension.dart';
import 'package:gs_orange/core/services/injection_container.dart';
import 'package:gs_orange/src/auth/data/models/user_model.dart';
import 'package:gs_orange/src/auth/presentation/bloc/auth_bloc.dart';
import 'package:gs_orange/src/auth/presentation/views/sign_in_screen.dart';
import 'package:gs_orange/src/auth/presentation/views/sign_up_screen.dart';
import 'package:gs_orange/src/dashboard/presentation/views/dashboard.dart';
import 'package:gs_orange/src/on_boarding/data/datasources/on_boarding_local_data_source.dart';
import 'package:gs_orange/src/on_boarding/presentation/cubit/on_boarding_cubit.dart';
import 'package:gs_orange/src/on_boarding/presentation/views/on_boarding_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as fui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'router.main.dart';
