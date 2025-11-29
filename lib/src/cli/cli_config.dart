class CliConfig {
  final String repositoryFile;
  final String featurePath;
  final String repositoryName;
  final bool isProMode;

  const CliConfig({
    required this.repositoryFile,
    required this.featurePath,
    required this.repositoryName,
    required this.isProMode,
  });
}
