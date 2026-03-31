import '../../../../../core/resources/helper_respons.dart';
import '../../../shared/models/quotation_model.dart';
import '../../domain/repositories/repository.dart';
import '../data_source/data_source.dart';

class QuotationListRepositoryImpl implements QuotationListRepository {
  final QuotationListDataSource _dataSource = QuotationListDataSourceImpl();

  @override
  Future<HelperResponse<List<Quotation>>> getAll({String? search}) {
    return _dataSource.getAll(search: search);
  }

  @override
  Future<HelperResponse<Quotation>> getById(int id) {
    return _dataSource.getById(id);
  }

  @override
  Future<HelperResponse<bool>> delete(int id) {
    return _dataSource.delete(id);
  }

  @override
  Future<HelperResponse<Quotation>> duplicate(int id) {
    return _dataSource.duplicate(id);
  }
}
