import 'package:flutter/material.dart';

class AskAdminScreen extends StatelessWidget {
  const AskAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Background grisâtre
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 100.0, left: 16.0, right: 16.0, bottom: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ask Question to Admin',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white, // Conteneur principal en blanc
                borderRadius: BorderRadius.circular(10), // Coins arrondis
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Subject',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 5),
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Input your text',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text(
                        'Your Query',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 5),
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200], // Fond gris pour la boîte de requête
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: const BoxDecoration(
                            color: Colors.white, // Fond blanc pour la barre d'outils
                            border: Border(bottom: BorderSide(color: Colors.grey)),
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildFormatIcon(Icons.format_bold),
                                _buildFormatIcon(Icons.format_italic),
                                _buildFormatIcon(Icons.format_underline),
                                _buildFormatIcon(Icons.sentiment_satisfied_alt),
                                _buildFormatIcon(Icons.link),
                                _buildFormatIcon(Icons.attach_file),
                                const SizedBox(width: 10),
                                const SizedBox(
                                  height: 24,
                                  child: VerticalDivider(color: Colors.grey, thickness: 1),
                                ),
                                _buildFormatIcon(Icons.format_list_bulleted),
                                _buildFormatIcon(Icons.format_align_left),
                                const SizedBox(width: 10),
                                const SizedBox(
                                  height: 24,
                                  child: VerticalDivider(color: Colors.grey, thickness: 1),
                                ),
                                _buildFormatIcon(Icons.arrow_back),
                                _buildFormatIcon(Icons.arrow_forward),
                              ],
                            ),
                          ),
                        ),
                        TextField(
                          maxLines: 10,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(10),
                            fillColor: Colors.grey[100], // Fond gris très clair pour le champ de saisie
                            filled: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDD1E1E), // Couleur rose
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Send',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Icon(icon, color: Colors.grey),
    );
  }
}