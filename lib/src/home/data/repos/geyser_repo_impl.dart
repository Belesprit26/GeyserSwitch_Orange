import 'package:dartz/dartz.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:gs_orange/core/errors/exceptions.dart';
import 'package:gs_orange/core/errors/failures.dart';
import 'package:gs_orange/core/utils/typdefs.dart';
import 'package:gs_orange/src/home/data/datasources/geyser_remote_data_source.dart';
import 'package:gs_orange/src/home/data/models/geyser_model.dart';
import 'package:gs_orange/src/home/domain/entities/geyser_entity.dart';
import 'package:gs_orange/src/home/domain/repos/geyser_repo.dart';

/// Implementation of GeyserRepo
/// Converts data layer models to domain entities and handles errors
class GeyserRepoImpl implements GeyserRepo {
  const GeyserRepoImpl(this._remoteDataSource);

  final GeyserRemoteDataSource _remoteDataSource;

  @override
  Stream<List<GeyserEntity>> getGeysersStream(String userId) {
    return _remoteDataSource.getGeysersStream(userId).map((geysersMap) {
      final geyserList = <GeyserEntity>[];

      geysersMap.forEach((geyserId, geyserData) {
        try {
          // Convert Firebase map to GeyserModel
          final model = GeyserModel.fromMap(
            geyserId,
            geyserData as Map<dynamic, dynamic>,
          );

          // Filter out disconnected geysers (temperature == -127)
          if (model.temperature != -127) {
            // Convert model to entity
            final entity = model.toEntity();
            geyserList.add(entity);
          }
        } catch (e) {
          // Silently skip invalid geyser data
          // In production, you might want to log this
          print('Error parsing geyser $geyserId: $e');
        }
      });

      // Sort the geyserList based on the geyser IDs (same logic as before)
      geyserList.sort((a, b) {
        int aId = int.tryParse(a.id.replaceAll('geyser_', '')) ?? 0;
        int bId = int.tryParse(b.id.replaceAll('geyser_', '')) ?? 0;
        return aId.compareTo(bId);
      });

      return geyserList;
    });
  }

  @override
  Stream<DatabaseEvent> getGeyserTemperatureStream(
    String userId,
    String geyserId,
    String sensorKey,
  ) {
    return _remoteDataSource.getGeyserTemperatureStream(
      userId,
      geyserId,
      sensorKey,
    );
  }

  @override
  Stream<DatabaseEvent> getGeyserStateStream(
    String userId,
    String geyserId,
  ) {
    return _remoteDataSource.getGeyserStateStream(userId, geyserId);
  }

  @override
  Stream<DatabaseEvent> getGeyserSensorStream(
    String userId,
    String geyserId,
    String sensorKey,
  ) {
    return _remoteDataSource.getGeyserSensorStream(
      userId,
      geyserId,
      sensorKey,
    );
  }

  @override
  ResultFuture<void> updateGeyserState(
    String userId,
    String geyserId,
    bool state,
  ) async {
    try {
      await _remoteDataSource.updateGeyserState(userId, geyserId, state);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
        statusCode: '500',
      ));
    }
  }

  @override
  ResultFuture<void> updateGeyserName(
    String userId,
    String geyserId,
    String name,
  ) async {
    try {
      await _remoteDataSource.updateGeyserName(userId, geyserId, name);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
        statusCode: '500',
      ));
    }
  }

  @override
  ResultFuture<double?> getMaxTemperature(
    String userId,
    String geyserId,
  ) async {
    try {
      final result = await _remoteDataSource.getMaxTemperature(
        userId,
        geyserId,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
        statusCode: '500',
      ));
    }
  }

  @override
  ResultFuture<void> updateMaxTemperature(
    String userId,
    String geyserId,
    double maxTemp,
  ) async {
    try {
      await _remoteDataSource.updateMaxTemperature(
        userId,
        geyserId,
        maxTemp,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
        statusCode: '500',
      ));
    }
  }

  @override
  Stream<DatabaseEvent> getGeyserStatsStream(String userId) {
    return _remoteDataSource.getGeyserStatsStream(userId);
  }
}

