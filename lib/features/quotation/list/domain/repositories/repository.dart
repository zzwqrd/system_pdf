import '../../../../../core/resources/helper_respons.dart';
import '../../../shared/models/quotation_model.dart';

abstract class QuotationListRepository {
  Future<HelperResponse<List<Quotation>>> getAll({String? search});
  Future<HelperResponse<Quotation>> getById(int id);
  Future<HelperResponse<bool>> delete(int id);
  Future<HelperResponse<Quotation>> duplicate(int id);
}
