/// Hatch — An in-app developer overlay for Flutter.
///
/// Switch environments, personas, feature flags, and inspect network
/// requests at runtime, without rebuilding.
library hatch;

export 'src/core/hatch.dart' show Hatch;
export 'src/core/hatch_state.dart' show HatchState;
export 'src/core/hatch_options.dart'
    show HatchOptions, HatchTrigger, HatchStyle, HatchTheme;
export 'src/models/hatch_environment.dart' show HatchEnvironment;
export 'src/models/hatch_persona.dart' show HatchPersona;
export 'src/models/hatch_credentials.dart' show HatchCredentials;
export 'src/models/hatch_flag.dart' show HatchFlag;
export 'src/models/hatch_shortcut.dart' show HatchShortcut;
export 'src/widgets/hatch_app.dart' show HatchApp;
export 'src/widgets/hatch_builder.dart' show HatchBuilder;
export 'src/network/hatch_interceptor.dart' show HatchInterceptor;
export 'src/network/hatch_http_client.dart' show HatchHttpClient;
