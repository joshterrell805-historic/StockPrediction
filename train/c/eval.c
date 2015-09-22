#include <stdio.h>
#include "floatfann.h"

int main()
{
  struct fann *ann = fann_create_from_file(
      "data/AAPL_ADBE_ATVI_COKE_EBAY_EXPE_NFLX_VA.300.net");
  struct fann_train_data *testData =
      fann_read_train_from_file("data/AAPL.test.pos.fann");


  int tp = 0, tn = 0, fp = 0, fn = 0;
  int a, p;
  fann_type *input, *actual, *predicted;
  for (int i = 0; i < testData->num_data; ++i) {
    input = testData->input[i];
    actual = testData->output[i];
    predicted = fann_run(ann, input);
    a = actual[0] >= 0;
    p = predicted[0] >= 0;
    if (i == 0) {
      printf("actual: %d  predicted: %d\n", a, p);
    }

    if (a) {
      if (p) ++tp;
      else ++fn;
    } else {
      if (p) ++fp;
      else ++tn;
    }
  }

  printf("\tap\tan\npp\t%d\t%d\npn\t%d\t%d\n", tp, fp, fn, tn);

  fann_destroy(ann);
  fann_destroy_train(testData);
  return 0;
}
