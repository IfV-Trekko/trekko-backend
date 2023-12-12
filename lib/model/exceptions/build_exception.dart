class BuildException<T> implements Exception {
  final T reason;

  BuildException(this.reason);

  T getReason() {
    return this.reason;
  }
}