import '../entities/data_warga_bangunan.dart';
import '../entities/data_warga_keluarga.dart';
import '../../../settings/domain/entities/app_user.dart';

abstract class DataWargaRepository {
  Future<List<String>> getRtList(AppUser user);
  Future<List<DataWargaBangunan>> getBangunanList(AppUser user, {String? searchQuery, String? rtFilter});
  Future<List<DataWargaKeluarga>> getKeluargaList(String bangunanId);
}
