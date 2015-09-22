#include "fann.h"

int main() {
  //unsigned int layers[] = {17, 500, 400, 300, 200, 1};
  //unsigned int layerCount = sizeof(layers) / sizeof(unsigned int);
  const char* netLoadFile =
      "data/AAPL_ADBE_ATVI_COKE_EBAY_EXPE_NFLX_VA.300.250.200_100.net";
  const char* netSaveFile =
      "data/AAPL_ADBE_ATVI_COKE_EBAY_EXPE_NFLX_VA.300.250.200_200.net";

  const float desired_error = (const float) 0.10;
  const unsigned int max_epochs = 100;
  const unsigned int epochs_between_reports = 1;

  //struct fann *ann = fann_create_standard_array(layerCount, layers);
  struct fann *ann = fann_create_from_file(netLoadFile);

  fann_set_activation_function_hidden(ann, FANN_SIGMOID_SYMMETRIC);
  fann_set_activation_function_output(ann, FANN_SIGMOID_SYMMETRIC);

  printf("%s\n", netSaveFile);

  fann_train_on_file(ann,
      "data/AAPL_ADBE_ATVI_COKE_EBAY_EXPE_NFLX_VA.train.fann", max_epochs,
      epochs_between_reports, desired_error);

  fann_save(ann, netSaveFile);

  fann_destroy(ann);

  printf("%s\n", netSaveFile);

  return 0;
}
