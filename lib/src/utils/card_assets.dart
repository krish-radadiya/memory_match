import 'package:flutter/material.dart';

class CardAsset {
  final String id;
  final String asset;
  final Color color;
  final String label;

  const CardAsset({required this.id, required this.asset, required this.color, required this.label});
}

const Map<String, CardAsset> cardAssetMap = {
  'A': CardAsset(id: 'A', asset: 'assets/images/watermelon.png', color: Color(0xFFF28B82), label: 'Watermelon'),
  'B': CardAsset(id: 'B', asset: 'assets/images/blueberry.png', color: Color(0xFF6C5CE7), label: 'Blueberry'),
  'C': CardAsset(id: 'C', asset: 'assets/images/mango.png', color: Color(0xFFFFD54F), label: 'Mango'),
  'D': CardAsset(id: 'D', asset: 'assets/images/chocolate-bar.png', color: Color(0xFF7B4F3B), label: 'Chocolate'),
  'E': CardAsset(id: 'E', asset: 'assets/images/mint.png', color: Color(0xFF2ECC71), label: 'Mint'),
  'F': CardAsset(id: 'F', asset: 'assets/images/passionfruit.png', color: Color(0xFFFF6F91), label: 'Passionfruit'),
};
