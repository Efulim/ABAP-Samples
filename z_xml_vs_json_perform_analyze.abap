*--------------------------------------------------------------------*
* Utku Y. ABAP XML vs Json Performance Analyze
*--------------------------------------------------------------------*
* Description:
*   Performance analyze for each process.
*--------------------------------------------------------------------*
* Change log:
*  30.01.2017 10:51:43 - BTC-UYEGEN
*--------------------------------------------------------------------*


REPORT z_xml_vs_json_perform_analyze.

DATA: lt_guid       TYPE crmt_object_guid_tab,
      lt_order      TYPE TABLE OF crms_order_read,
      ls_order      TYPE crms_order_read,
      lv_xml        TYPE string,
      lv_json       TYPE string,
      lt_order_xml  TYPE TABLE OF crms_order_read,
      lt_order_json TYPE TABLE OF crms_order_read.

DEFINE write_date_n_time.
  get time.
  write:/ | { sy-datum DATE = environment } { sy-uzeit TIME = environment } |.
END-OF-DEFINITION.
DEFINE write_string_len.
  WRITE:/ |{ &1 }`s length character count is { strlen( &2 ) NUMBER = environment }|.
END-OF-DEFINITION.
DEFINE write_title.
  WRITE:/ &1.
END-OF-DEFINITION.
DEFINE write_uline.
  uline.
END-OF-DEFINITION.
DEFINE write_table_line.
  WRITE:/ |Total lines of itab is..: { lines( &1 ) }|.
END-OF-DEFINITION.

PERFORM get_data. " get data from DB
PERFORM xml_convertion.
PERFORM json_convertion.
PERFORM xml_reconvertion.
PERFORM json_reconvertion.

*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*----------------------------------------------------------------------*
FORM get_data .

* read order
  SELECT guid UP TO 200 ROWS
    FROM crmd_orderadm_h
    INTO TABLE lt_guid.
  write_table_line: lt_guid.

  CALL FUNCTION 'CRM_ORDER_READ'
    EXPORTING
      it_header_guid          = lt_guid
      iv_mode                 = 'C'
    IMPORTING
      et_orderadm_h           = ls_order-orderadm_h
      et_opport_h             = ls_order-opport_h
      et_lead_h               = ls_order-lead_h
      et_activity_h           = ls_order-activity_h
      et_orderadm_i           = ls_order-orderadm_i
      et_product_i            = ls_order-product_i
      et_finprod_i            = ls_order-finprod_i
      et_config               = ls_order-config
      et_struct_i             = ls_order-struct_i
      et_sales                = ls_order-sales
      et_pricing              = ls_order-pricing
      et_pricing_i            = ls_order-pricing_i
      et_orgman               = ls_order-orgman
      et_shipping             = ls_order-shipping
      et_customer_h           = ls_order-customer_h
      et_customer_i           = ls_order-customer_i
      et_service_h            = ls_order-service_h
      et_service_i            = ls_order-service_i
      et_service_assign       = ls_order-service_assign
      et_payplan              = ls_order-payplan
      et_payplan_d            = ls_order-payplan_d
      et_appointment          = ls_order-appointment
      et_text                 = ls_order-text
      et_schedlin             = ls_order-schedlin
      et_partner              = ls_order-partner
      et_service_os           = ls_order-service_os
      et_cumulat_h            = ls_order-cumulat_h
      et_status               = ls_order-status
      et_status_h             = ls_order-status_h
      et_schedlin_i           = ls_order-schedlin_i
      et_cancel               = ls_order-cancel
      et_cancel_ir            = ls_order-cancel_ir
      et_billplan             = ls_order-billplan
      et_billing              = ls_order-billing
      et_ordprp_i             = ls_order-ordprp_i
      et_ordprp_i_d           = ls_order-ordprp_i_d
      et_ordprp_objl_i_d      = ls_order-ordprp_objl_i_d
      et_cumulated_i          = ls_order-cumulated_i
      et_doc_flow             = ls_order-doc_flow
      et_exception            = ls_order-exception
      et_price_agreements_crm = ls_order-price_agreements_crm
      et_price_agreements_bbp = ls_order-price_agreements_bbp
      et_config_filter        = ls_order-config_filter
      et_pridoc               = ls_order-pridoc
    EXCEPTIONS
      document_not_found      = 1
      error_occurred          = 2
      document_locked         = 3
      no_change_authority     = 4
      no_display_authority    = 5
      no_change_allowed       = 6
      OTHERS                  = 7.
  APPEND ls_order TO lt_order.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  XML_CONV
*----------------------------------------------------------------------*
FORM xml_convertion .
* xml convertion
  write_title: 'XML Convertion'.
  write_date_n_time.
  CALL TRANSFORMATION ('ID') SOURCE tab = lt_order[] RESULT XML lv_xml.
  write_date_n_time.
  write_string_len: 'XML' lv_xml.
  write_uline.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  JSON_CONVERTION
*----------------------------------------------------------------------*
FORM json_convertion .
* json convertion
  write_title: 'JSON Convertion'.
  write_date_n_time.
  lv_json = /ui2/cl_json=>serialize( EXPORTING data = lt_order compress = abap_true pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).
  write_date_n_time.
  write_string_len: 'JSON' lv_json.
  write_uline.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  XML_RECONVERTION
*----------------------------------------------------------------------*
FORM xml_reconvertion .
* xml re-convert to itab
  write_title: 'XML Re-Convertion'.
  write_date_n_time.
  CALL TRANSFORMATION ('ID') SOURCE xml = lv_xml RESULT tab = lt_order_xml.
  write_date_n_time.
  write_uline.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  JSON_RECONVERTION
*----------------------------------------------------------------------*
FORM json_reconvertion .
* json re-convert to itab
  write_title: 'JSON Re-Convertion'.
  write_date_n_time.
  /ui2/cl_json=>deserialize( EXPORTING json = lv_json CHANGING data = lt_order_json ).
  write_date_n_time.
  write_uline.
ENDFORM.
