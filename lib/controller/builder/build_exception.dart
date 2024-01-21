class BuildException<T> {
  final T reason;
  final Exception? cause;

  BuildException(this.cause, this.reason);
}
