class BuildException<T> {
  final T reason;

  BuildException(this.reason);

  T getReason() {
    return this.reason;
  }
}