Future<T> retry<T>(
    Future<T> Function() task, {
      int retries = 3,
      Duration delay = const Duration(seconds: 2),
    }) async {
  try {
    return await task();
  } catch (e) {
    if (retries == 0) rethrow;
    await Future.delayed(delay);
    return retry(
      task,
      retries: retries - 1,
      delay: delay * 2,
    );
  }
}
