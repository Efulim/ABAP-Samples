*&---------------------------------------------------------------------*
*& Report ZPPOMA_ATTRIBUTE_UPDATE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zppoma_attribute_update.

DATA: gt_attr_tab TYPE STANDARD TABLE OF pt1222.

SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME.
PARAMETERS:
  pa_otype TYPE otype DEFAULT 'O'        OBLIGATORY,
  pa_objid TYPE realo DEFAULT '50000000' OBLIGATORY,
  pa_adrem TYPE flag  DEFAULT 'X'. " Add / Remove
SELECTION-SCREEN: END OF BLOCK b1.

START-OF-SELECTION.
  PERFORM sos.

END-OF-SELECTION.
  PERFORM eos.

*--------------------------------------------------------------------*
*--------------------------------------------------------------------*
*--------------------------------------------------------------------*
*--------------------------------------------------------------------*
*--------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  SOS
*----------------------------------------------------------------------*
FORM sos .

* prepare attributes table
  DATA: ls_attr_tab LIKE LINE OF gt_attr_tab.

  DEFINE a.
    CLEAR: ls_attr_tab.

    ls_attr_tab-attrib = &1.
    ls_attr_tab-low = &2.

    APPEND ls_attr_tab TO gt_attr_tab.
  END-OF-DEFINITION.

  IF pa_adrem EQ abap_true.
    a:
      'ZATTR1' '41',
      'ZATTR2' 'Z000',
      'ZATTR2' 'Z001'.
  ELSEIF pa_adrem EQ abap_false.
    a:
      'ZATTR1' '',
      'ZATTR2' ''.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  EOS
*----------------------------------------------------------------------*
FORM eos .
  CALL FUNCTION 'RH_OM_ATTRIBUTES_UPDATE'
    EXPORTING
      otype               = pa_otype
      objid               = pa_objid
      scenario            = 'SERVICE'
    TABLES
      attr_tab            = gt_attr_tab
    EXCEPTIONS
      no_active_plvar     = 1
      object_not_found    = 2
      no_attributes       = 3
      times_invalid       = 4
      inconsistent_values = 5
      update_error        = 6
      nothing_to_update   = 7
      OTHERS              = 8.
  DATA(m) = |sy-subrc = { sy-subrc }|.
  MESSAGE m TYPE 'I'.
  IF sy-subrc EQ 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = abap_true.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ENDIF.
ENDFORM.