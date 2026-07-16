// ignore_for_file: constant_identifier_names

import 'dart:ui' show PointerDeviceKind, Offset;

import 'package:flutter/material.dart'
    show MaterialScrollBehavior, BouncingScrollPhysics, ScrollBehavior;

// From Path Approximator
const double BEZIER_TOLERANCE = 0.25;
const int CATMULL_DETAIL = 50;
const int CATMULL_SEGMENT_LENGTH = CATMULL_DETAIL * 2;
const double CIRCULAR_ARC_TOLERANCE = 0.1;
const int LAGRANGE_STEPS = 51;

// From Precision
const EPSILON = 1e-7;

// From Replay parser
const RANDOM_SEED_DELTA = -12345;

// From (base) Hit Object
const Offset STACK_OFFSET = Offset(4.0, 4.0);
const Offset SPINNER_CENTRE = Offset(256, 192);

// From Logger
const int MAX_LOG_TIME = 20;

// From Osu Logo
const double LOGO_SIZE = 512.0;

// From Frame Stats
const int TIMINGS_SIZE = 100;

// From Scroll config
// Isn't a constant, but it's used in multiple places
final ScrollBehavior defaultScrollBehavior = const MaterialScrollBehavior()
    .copyWith(
      dragDevices: PointerDeviceKind.values.toSet(),
      physics: const BouncingScrollPhysics(),
      scrollbars: false,
      overscroll: false,
    );
