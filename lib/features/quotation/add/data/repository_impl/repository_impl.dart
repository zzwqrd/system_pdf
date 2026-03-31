import '../../../../../core/resources/helper_respons.dart';
import '../../../shared/models/quotation_model.dart';
import '../../domain/repositories/repository.dart';
import '../data_source/data_source.dart';
import '../model/send_data.dart';

class AddQuotationRepositoryImpl implements AddQuotationRepository {
  final AddQuotationDataSource _dataSource = AddQuotationDataSourceImpl();

  @override
  Future<HelperResponse<Quotation>> addQuotation(
      QuotationSendData sendData) {
    return _dataSource.addQuotation(sendData);
  }
}
