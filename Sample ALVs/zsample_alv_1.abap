REPORT zsample_alv_1.

DATA: gv_tmp_crea TYPE datum,
      gv_tmp_chan TYPE datum.

SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME.
PARAMETERS:
  pa_ptype TYPE crmt_process_type VISIBLE LENGTH 10 AS LISTBOX.
SELECT-OPTIONS:
  so_crea FOR gv_tmp_crea,
  so_chan FOR gv_tmp_chan.
SELECTION-SCREEN: END OF BLOCK b1.

AT SELECTION-SCREEN OUTPUT.
  PERFORM at_selection_screen_output.

START-OF-SELECTION.
  PERFORM run_the_world.

**********************************************************************
**********************************************************************
**********************************************************************
**********************************************************************
**********************************************************************

*&---------------------------------------------------------------------*
*&      Form  RUN_THE_WORLD
*&---------------------------------------------------------------------*
FORM run_the_world .
  PERFORM get_data.
  PERFORM show_alv.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
FORM get_data .
  DATA: ra_crea TYPE RANGE OF comt_created_at_usr,
        ra_chan TYPE RANGE OF comt_changed_at_usr.

  PERFORM calc_timestamp_range CHANGING ra_crea[] ra_chan[].
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SHOW_ALV
*&---------------------------------------------------------------------*
FORM show_alv .

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AT_SELECTION_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
FORM at_selection_screen_output .
  DATA: vrm_id     TYPE vrm_id,
        vrm_values TYPE vrm_values,
        vrm_value  LIKE LINE OF vrm_values.

  DEFINE add_value.
    CLEAR vrm_value.
    vrm_value-key = &1.
    vrm_value-text = &2.
    APPEND vrm_value TO vrm_values.
  END-OF-DEFINITION.

  add_value:
    '' '',
    'Z001' 'Process Type 1',
    'Z002' 'Process Type 2',
    'Z003' 'Process Type 3'.
  vrm_id = 'pa_ptype'.
  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id              = vrm_id
      values          = vrm_values
    EXCEPTIONS
      id_illegavrm_id = 1
      OTHERS          = 2.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CALC_TIMESTAMP_RANGE
*&---------------------------------------------------------------------*
FORM calc_timestamp_range  CHANGING p_ra_crea p_ra_chan.
  CONSTANTS: lc_uzeit_start TYPE uzeit VALUE '000000',
             lc_uzeit_end   TYPE uzeit VALUE '235959'.
  DATA: ra_crea TYPE RANGE OF comt_created_at_usr,
        ra_chan TYPE RANGE OF comt_changed_at_usr.

  LOOP AT so_crea[] ASSIGNING FIELD-SYMBOL(<fs_crea>).
    APPEND INITIAL LINE TO ra_crea ASSIGNING FIELD-SYMBOL(<fs_ra_crea>).
    <fs_ra_crea>-sign = <fs_crea>-sign.
    <fs_ra_crea>-option = 'BT'.
    CONVERT DATE <fs_crea>-low TIME lc_uzeit_start INTO TIME STAMP <fs_ra_crea>-low TIME ZONE sy-zonlo.
    IF <fs_crea>-high IS INITIAL.
      CONVERT DATE <fs_crea>-low TIME lc_uzeit_end INTO TIME STAMP <fs_ra_crea>-high TIME ZONE sy-zonlo.
    ELSE.
      CONVERT DATE <fs_crea>-high TIME lc_uzeit_end INTO TIME STAMP <fs_ra_crea>-high TIME ZONE sy-zonlo.
    ENDIF.
  ENDLOOP.

  LOOP AT so_chan[] ASSIGNING FIELD-SYMBOL(<fs_chan>).
    APPEND INITIAL LINE TO ra_chan ASSIGNING FIELD-SYMBOL(<fs_ra_chan>).
    <fs_ra_chan>-sign = <fs_chan>-sign.
    <fs_ra_chan>-option = 'BT'.
    CONVERT DATE <fs_chan>-low TIME lc_uzeit_start INTO TIME STAMP <fs_ra_chan>-low TIME ZONE sy-zonlo.
    IF <fs_chan>-high IS INITIAL.
      CONVERT DATE <fs_chan>-low TIME lc_uzeit_end INTO TIME STAMP <fs_ra_chan>-high TIME ZONE sy-zonlo.
    ELSE.
      CONVERT DATE <fs_chan>-high TIME lc_uzeit_end INTO TIME STAMP <fs_ra_chan>-high TIME ZONE sy-zonlo.
    ENDIF.
  ENDLOOP.

  p_ra_crea = ra_crea.
  p_ra_chan = ra_chan.
ENDFORM.
