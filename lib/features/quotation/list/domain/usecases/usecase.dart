import '../../../../../core/resources/helper_respons.dart';
import '../../../shared/models/quotation_model.dart';
import '../../data/repository_impl/repository_impl.dart';
import '../repositories/repository.dart';

abstract class QuotationListUseCase {
  Future<HelperResponse<List<Quotation>>> getAll({String? search});
  Future<HelperResponse<Quotation>> getById(int id);
  Future<HelperResponse<bool>> delete(int id);
  Future<HelperResponse<Quotation>> duplicate(int id);
}

class QuotationListUseCaseImpl implements QuotationListUseCase {
  final QuotationListRepository _repository = QuotationListRepositoryImpl();

  @override
  Future<HelperResponse<List<Quotation>>> getAll({String? search}) {
    return _repository.getAll(search: search);
  }

  @override
  Future<HelperResponse<Quotation>> getById(int id) {
    return _repository.getById(id);
  }

  @override
  Future<HelperResponse<bool>> delete(int id) {
    return _repository.delete(id);
  }

  @override
  Future<HelperResponse<Quotation>> duplicate(int id) {
    return _repository.duplicate(id);
  }
}
