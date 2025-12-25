import 'package:currency_converter/features/home/data/datasources/conversion_remote_data_source.dart';
import 'package:currency_converter/features/home/domain/entities/conversion_result.dart';
import 'package:currency_converter/features/home/domain/repositories/conversion_repository.dart';

/// Implementation of [ConversionRepository].
///
/// This class coordinates between data sources and converts
/// data models to domain entities.
class ConversionRepositoryImpl implements ConversionRepository {
  ConversionRepositoryImpl({
    required ConversionRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final ConversionRemoteDataSource _remoteDataSource;

  @override
  Future<ConversionResult> convert({
    required String from,
    required String to,
    required double amount,
  }) async {
    final result = await _remoteDataSource.convert(
      from: from,
      to: to,
      amount: amount,
    );

    return result.toEntity();
  }
}
