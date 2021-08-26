import 'package:fluffychat/stats_dashboard/models/drop_down_item_model.dart';
import 'package:flutter/material.dart';

final List<DropDownItemsModel> dropdownItems = [
  DropDownItemsModel(1, 'TODAS', true),
  DropDownItemsModel(2, 'BUENOS AIRES', true),
  DropDownItemsModel(3, 'CABA', true),
  DropDownItemsModel(4, 'CATAMARCA', true),
  DropDownItemsModel(5, 'CHACO', true),
  DropDownItemsModel(6, 'CHUBUT', true),
  DropDownItemsModel(7, 'CORDOBA', true),
  DropDownItemsModel(8, 'CORRIENTES', true),
  DropDownItemsModel(9, 'ENTRE RÍOS', true),
  DropDownItemsModel(10, 'FORMOSA', true),
  DropDownItemsModel(11, 'JUJUY', true),
/*  DropDownItemsModel(34, 'Manuel Belgrano', false),
  DropDownItemsModel(35, 'San Pedro', false), */
  DropDownItemsModel(12, 'LA PAMPA', true),
  DropDownItemsModel(13, 'LA RIOJA', true),
  DropDownItemsModel(14, 'MENDOZA', true),
  DropDownItemsModel(15, 'MISIONES', true),
  DropDownItemsModel(16, 'NEUQUEN', true),
  DropDownItemsModel(17, 'RIO NEGRO', true),
  DropDownItemsModel(18, 'SALTA', true),
  DropDownItemsModel(19, 'SAN JUAN', true),
  DropDownItemsModel(20, 'SAN LUIS', true),
  DropDownItemsModel(21, 'SANTA CRUZ', true),
  DropDownItemsModel(22, 'SANTA FE', true),
  DropDownItemsModel(23, 'SANTIAGO DEL ESTERO', true),
  DropDownItemsModel(24, 'TIERRA DEL FUEGO', true),
  DropDownItemsModel(25, 'TUCUMÁN', true),
];

List<DropdownMenuItem<DropDownItemsModel>> buildDropDownMenuItems(
    List listItems) {
  // ignore: omit_local_variable_types
  List<DropdownMenuItem<DropDownItemsModel>> items = [];
  for (DropDownItemsModel listItem in listItems) {
    items.add(
      DropdownMenuItem(
        child: listItem.isPrimay
            ? Text(
                listItem.name,
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            : Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  listItem.name,
                  style: TextStyle(
                    fontSize: 10.0,
                  ),
                ),
              ),
        value: listItem,
      ),
    );
  }
  return items;
}

String getProvinciaValue(int value) {
  switch (value) {
    case 1:
      return '';
      break;
    case 2:
      return '&provincia=bue';
      break;
    case 3:
      return '&provincia=cab';
      break;
    case 4:
      return '&provincia=cat';
      break;
    case 5:
      return '&provincia=cha';
      break;
    case 6:
      return '&provincia=chu';
      break;
    case 7:
      return '&provincia=cob';
      break;
    case 8:
      return '&provincia=cor';
      break;
    case 9:
      return '&provincia=ent';
      break;
    case 10:
      return '&provincia=for';
      break;
    case 11:
      return '&provincia=juj';
      break;
    case 12:
      return '&provincia=lap';
      break;
    case 13:
      return '&provincia=rio';
      break;
    case 14:
      return '&provincia=men';
      break;
    case 15:
      return '&provincia=mis';
      break;
    case 16:
      return '&provincia=neu';
      break;
    case 17:
      return '&provincia=rne';
      break;
    case 18:
      return '&provincia=sal';
      break;
    case 19:
      return '&provincia=sju';
      break;
    case 20:
      return '&provincia=slu';
      break;
    case 21:
      return '&provincia=scz';
      break;
    case 22:
      return '&provincia=sfe';
      break;
    case 23:
      return '&provincia=stg';
      break;
    case 24:
      return '&provincia=tfu';
      break;
    case 25:
      return '&provincia=tuc';
      break;

/*
    case 15:
      return '&provincia=bue-altbr';
      break;
    case 16:
      return '&provincia=bue-lanus';
      break;
    case 17:
      return '&provincia=bue-moron';
      break;
    case 18:
      return '&provincia=bue-sisidro';
      break;
    case 19:
      return '&provincia=bue-smartin';
      break;
    case 20:
      return '&provincia=bue-quilmes';
      break;

    case 21:
      return '&provincia=cat-capit';
      break;
    case 22:
      return '&provincia=cat-belen';
      break;
    case 23:
      return '&provincia=cat-vviejo';
      break;

    case 24:
      return '&provincia=cha-sferan';
      break;
    case 25:
      return '&provincia=cha-guemes';
      break;
    case 26:
      return '&provincia=cha-chacab';
      break;

    case 27:
      return '&provincia=cor-capit';
      break;
    case 28:
      return '&provincia=cor-goya';
      break;

    case 29:
      return '&provincia=ent-parana';
      break;
    case 30:
      return '&provincia=ent-concor';
      break;
    case 31:
      return '&provincia=ent-gualchu';
      break;

    case 32:
      return '&provincia=for-capit';
      break;
    case 33:
      return '&provincia=for-pilco';
      break;

    case 34:
      return '&provincia=juj-belgrano';
      break;
    case 35:
      return '&provincia=juj-spedro';
      break;

    case 36:
      return '&provincia=rio-capit';
      break;
    case 37:
      return '&provincia=rio-chile';
      break;
    case 38:
      return '&provincia=rio-verapenia';
      break;

    case 39:
      return '&provincia=mis-capit';
      break;
    case 40:
      return '&provincia=mis-guarani';
      break;
    case 41:
      return '&provincia=mis-obera';
      break;

    case 42:
      return '&provincia=sal-capit';
      break;
    case 43:
      return '&provincia=sal-oran';
      break;

    case 44:
      return '&provincia=stg-capit';
      break;
    case 45:
      return '&provincia=stg-banda';
      break;
    case 46:
      return '&provincia=stg-riohon';
      break;
    case 47:
      return '&provincia=stg-drobles';
      break;

    case 48:
      return '&provincia=tuc-capit';
      break;
    case 49:
      return '&provincia=tuc-tafiv';
      break;
    case 50:
      return '&provincia=tuc-cruzalta';
      break; */

    default:
      return '';
  }
}
