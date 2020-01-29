" concatenate fields at SELECT
SELECT SINGLE CASE type
       WHEN '1' THEN name_first && ' ' && name_last
       WHEN '2' THEN name_org1 && ' ' && name_org2
       END AS name,
       partner_guid
  FROM but000
  INTO @DATA(lv_full_name)
 WHERE partner_guid eq @lv_bp_partner_guid.
