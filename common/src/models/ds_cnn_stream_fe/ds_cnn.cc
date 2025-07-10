#include "models/ds_cnn_stream_fe/ds_cnn.h"
#include <stdio.h>
#include "menu.h"
#include "models/ds_cnn_stream_fe/ds_cnn_stream_fe.h"
#include "tflite.h"
#include "models/label/label0_board.h"
#include "models/label/label1_board.h"
#include "models/label/label6_board.h"
#include "models/label/label8_board.h"
#include "models/label/label11_board.h"


// Initialize everything once
// deallocate tensors when done
static void ds_cnn_stream_fe_init(void) {
  tflite_load_model(ds_cnn_stream_fe, ds_cnn_stream_fe_len);
}

// TODO: Implement your design here

static void print_result_classification(float *data) 
{
    int i = 0;
    for (i = 0; i < 12; ++i) {
        printf(" %d : 0x%08lx,\n", i, *(uint32_t *)&data[i]);
    }
}

static void do_init_zeros_input(void) 
{
    tflite_set_input_zeros_float();
    tflite_classify();
    float *data =  tflite_get_output_float();
    print_result_classification(data);
}

static void do_init_label0(void) 
{
    tflite_set_input_float(label0_data);
    tflite_classify();
    float *data =  tflite_get_output_float();
    print_result_classification(data);
}


static void do_init_label1(void) 
{
    tflite_set_input_float(label1_data);
    tflite_classify();
    float *data =  tflite_get_output_float();
    print_result_classification(data);
}

static void do_init_label6(void) 
{
    tflite_set_input_float(label6_data);
    tflite_classify();
    float *data =  tflite_get_output_float();
    print_result_classification(data);
}

static void do_init_label8(void) 
{
    tflite_set_input_float(label8_data);
    tflite_classify();
    float *data =  tflite_get_output_float();
    print_result_classification(data);
}

static void do_init_label11(void) 
{
    tflite_set_input_float(label11_data);
    tflite_classify();
    float *data =  tflite_get_output_float();
    print_result_classification(data);
}

static void do_golden_tests(void)
{
    do_init_label0();
    do_init_label1();
    do_init_label6();
    do_init_label8();
    do_init_label11();
}
static struct Menu MENU = {
    "Tests for ds_cnn_stream_fe",
    "ds_cnn_stream_fe",
    {
        MENU_ITEM('1', "Run with zeros input", do_init_zeros_input),
        MENU_ITEM('2', "Run with label0", do_init_label0),
        MENU_ITEM('3', "Run with label1", do_init_label1),
        MENU_ITEM('4', "Run with label6", do_init_label6),
        MENU_ITEM('5', "Run with label8", do_init_label8),
        MENU_ITEM('6', "Run with label11", do_init_label11),
        MENU_ITEM('g', "Run golden tests (check for expected outputs)", do_golden_tests),
        MENU_END,
    },
};

// For integration into menu system
void ds_cnn_stream_fe_menu() {
  ds_cnn_stream_fe_init();
  menu_run(&MENU);
}

