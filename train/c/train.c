#include "fann.h"

int main() {
  unsigned int layers[] = {17, 300, 250, 200, 150, 100, 1};
  unsigned int layerCount = sizeof(layers) / sizeof(unsigned int);

  const float desired_error = (const float) 0.01;
  const unsigned int max_epochs = 5000;
  const unsigned int epochs_between_reports = 10;

  struct fann *ann = fann_create_standard_array(layerCount, layers);

  fann_set_activation_function_hidden(ann, FANN_SIGMOID_SYMMETRIC);
  fann_set_activation_function_output(ann, FANN_SIGMOID_SYMMETRIC);

  fann_train_on_file(ann, "data/AAPL.train.fann", max_epochs,
      epochs_between_reports, desired_error);

  fann_save(ann, "data/AAPL.300.250.200.150.100.net");

  fann_destroy(ann);

  return 0;
}
