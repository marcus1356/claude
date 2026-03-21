/// Landing page pública do CuidadoIntegrado.
///
/// Apresenta a proposta de valor da plataforma e direciona
/// o visitante ao cadastro ou login.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  static const _primaryGreen = Color(0xFF00695C);
  static const _darkGreen = Color(0xFF004D40);
  static const _primaryBlue = Color(0xFF1565C0);
  static const _lightGreen = Color(0xFFE0F2F1);
  static const _textDark = Color(0xFF212121);
  static const _textGrey = Color(0xFF616161);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 800;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildNavbar(context),
            _buildHero(context, isWide),
            _buildStats(context, isWide),
            _buildValueProps(context, isWide),
            _buildForWhom(context, isWide),
            _buildHowItWorks(context, isWide),
            _buildFinalCta(context),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  // ── NAVBAR ──────────────────────────────────────────────────────────────────

  Widget _buildNavbar(BuildContext context) {
    return Container(
      color: _primaryGreen,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Row(
        children: [
          const Icon(Icons.health_and_safety, color: Colors.white, size: 28),
          const SizedBox(width: 10),
          Text(
            'CuidadoIntegrado',
            style: GoogleFonts.notoSans(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/login'),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: const Text('Entrar', style: TextStyle(fontSize: 15)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/register'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _primaryGreen,
              minimumSize: const Size(0, 40),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Cadastrar',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ── HERO ────────────────────────────────────────────────────────────────────

  Widget _buildHero(BuildContext context, bool isWide) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primaryGreen, _darkGreen],
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 80 : 24,
        vertical: isWide ? 80 : 48,
      ),
      child: Column(
        crossAxisAlignment:
            isWide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Plataforma de saúde inclusiva',
              style: GoogleFonts.notoSans(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Cuidado especializado\npara quem mais precisa',
            textAlign: isWide ? TextAlign.start : TextAlign.center,
            style: GoogleFonts.notoSans(
              color: Colors.white,
              fontSize: isWide ? 48 : 34,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Text(
              'Conectamos pessoas com deficiência, idosos e familiares '
              'a profissionais de saúde especializados — com agilidade, '
              'acessibilidade e confiança.',
              textAlign: isWide ? TextAlign.start : TextAlign.center,
              style: GoogleFonts.notoSans(
                color: Colors.white.withOpacity(0.9),
                fontSize: 17,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 36),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: isWide ? WrapAlignment.start : WrapAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/register'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _primaryGreen,
                  minimumSize: const Size(0, 52),
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  'Criar conta gratuita',
                  style: GoogleFonts.notoSans(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 1.5),
                  minimumSize: const Size(0, 52),
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'Já tenho conta',
                  style: GoogleFonts.notoSans(fontSize: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── STATS ───────────────────────────────────────────────────────────────────

  Widget _buildStats(BuildContext context, bool isWide) {
    final stats = [
      ('4 tipos', 'de perfil de usuário'),
      ('100%', 'gratuito para cadastro'),
      ('4 especialidades', 'de saúde disponíveis'),
      ('Acessível', 'para todos os públicos'),
    ];

    return Container(
      color: _lightGreen,
      padding: EdgeInsets.symmetric(
          horizontal: isWide ? 80 : 24, vertical: 40),
      child: Wrap(
        spacing: 32,
        runSpacing: 24,
        alignment: WrapAlignment.spaceAround,
        children: stats.map((s) {
          return SizedBox(
            width: isWide ? 180 : double.infinity,
            child: Column(
              children: [
                Text(
                  s.$1,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSans(
                    color: _primaryGreen,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  s.$2,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSans(
                    color: _textGrey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── VALUE PROPOSITIONS ───────────────────────────────────────────────────────

  Widget _buildValueProps(BuildContext context, bool isWide) {
    final props = [
      (
        Icons.connect_without_contact,
        'Conexão direta',
        'Encontre profissionais especializados e entre em contato sem intermediários, '
            'de forma simples e rápida.',
      ),
      (
        Icons.verified_user,
        'Profissionais qualificados',
        'Fisioterapeutas, psicólogos, neurologistas e nutricionistas com registro '
            'profissional verificado.',
      ),
      (
        Icons.health_and_safety,
        'Convênio aceito',
        'Filtre profissionais que atendem pelo seu plano de saúde e evite '
            'surpresas no momento do atendimento.',
      ),
      (
        Icons.accessibility_new,
        'Plataforma acessível',
        'Desenvolvida com foco em acessibilidade para pessoas com deficiência, '
            'idosos e seus cuidadores.',
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: isWide ? 80 : 24, vertical: 64),
      child: Column(
        children: [
          _sectionLabel('Por que o CuidadoIntegrado?'),
          const SizedBox(height: 12),
          Text(
            'Tudo o que você precisa para\ncuidar de quem você ama',
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSans(
              color: _textDark,
              fontSize: isWide ? 32 : 24,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 48),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.center,
            children: props.map((p) {
              return SizedBox(
                width: isWide ? 260 : double.infinity,
                child: _valuePropCard(
                    context, p.$1, p.$2, p.$3),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _valuePropCard(
      BuildContext context, IconData icon, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _lightGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _primaryGreen, size: 28),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: GoogleFonts.notoSans(
              color: _textDark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            desc,
            style: GoogleFonts.notoSans(
              color: _textGrey,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ── FOR WHOM ────────────────────────────────────────────────────────────────

  Widget _buildForWhom(BuildContext context, bool isWide) {
    final profiles = [
      (
        Icons.medical_services,
        'Profissionais de Saúde',
        'Fisioterapeutas, psicólogos, neurologistas e nutricionistas que '
            'queiram ampliar sua rede de pacientes.',
        _primaryBlue,
      ),
      (
        Icons.accessibility_new,
        'Pessoas com Deficiência',
        'Encontre profissionais especializados no seu tipo de necessidade '
            'com facilidade e segurança.',
        _primaryGreen,
      ),
      (
        Icons.elderly,
        'Pessoas Idosas',
        'Acesse cuidados de saúde de qualidade com profissionais que '
            'entendem as necessidades da terceira idade.',
        Color(0xFF6A1B9A),
      ),
      (
        Icons.family_restroom,
        'Familiares e Cuidadores',
        'Gerencie o cuidado de quem você ama com suporte profissional '
            'e orientações especializadas.',
        Color(0xFFE65100),
      ),
    ];

    return Container(
      color: const Color(0xFFF5F5F5),
      padding: EdgeInsets.symmetric(
          horizontal: isWide ? 80 : 24, vertical: 64),
      child: Column(
        children: [
          _sectionLabel('Para quem é?'),
          const SizedBox(height: 12),
          Text(
            'Uma plataforma para todos\nque fazem parte do cuidado',
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSans(
              color: _textDark,
              fontSize: isWide ? 32 : 24,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 48),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.center,
            children: profiles.map((p) {
              return SizedBox(
                width: isWide ? 260 : double.infinity,
                child: _profileCard(p.$1, p.$2, p.$3, p.$4),
              );
            }).toList(),
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/register'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryGreen,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 54),
              padding: const EdgeInsets.symmetric(horizontal: 40),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Criar minha conta agora',
              style: GoogleFonts.notoSans(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileCard(
      IconData icon, String title, String desc, Color color) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: GoogleFonts.notoSans(
              color: _textDark,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            desc,
            style: GoogleFonts.notoSans(
              color: _textGrey,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ── HOW IT WORKS ────────────────────────────────────────────────────────────

  Widget _buildHowItWorks(BuildContext context, bool isWide) {
    final steps = [
      (
        '1',
        Icons.person_add,
        'Crie sua conta',
        'Cadastre-se gratuitamente escolhendo seu perfil: profissional, '
            'paciente, idoso ou familiar.',
      ),
      (
        '2',
        Icons.search,
        'Encontre o profissional',
        'Busque por especialidade, localização ou convênio e encontre '
            'o profissional ideal para você.',
      ),
      (
        '3',
        Icons.favorite,
        'Receba o cuidado',
        'Entre em contato diretamente com o profissional e comece '
            'sua jornada de cuidado com mais qualidade de vida.',
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: isWide ? 80 : 24, vertical: 64),
      child: Column(
        children: [
          _sectionLabel('Como funciona?'),
          const SizedBox(height: 12),
          Text(
            'Em 3 passos simples\nvocê já está conectado',
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSans(
              color: _textDark,
              fontSize: isWide ? 32 : 24,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 48),
          Wrap(
            spacing: 24,
            runSpacing: 32,
            alignment: WrapAlignment.center,
            children: steps.map((s) {
              return SizedBox(
                width: isWide ? 280 : double.infinity,
                child: _stepCard(s.$1, s.$2, s.$3, s.$4),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _stepCard(
      String number, IconData icon, String title, String desc) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _lightGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: _primaryGreen, size: 32),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: _primaryGreen,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  number,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.notoSans(
            color: _textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          desc,
          textAlign: TextAlign.center,
          style: GoogleFonts.notoSans(
            color: _textGrey,
            fontSize: 14,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  // ── FINAL CTA ───────────────────────────────────────────────────────────────

  Widget _buildFinalCta(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primaryGreen, _darkGreen],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 72),
      child: Column(
        children: [
          Text(
            'Comece hoje mesmo',
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSans(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Junte-se à plataforma que conecta quem cuida\na quem precisa de cuidado.',
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSans(
              color: Colors.white.withOpacity(0.9),
              fontSize: 17,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 36),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/register'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _primaryGreen,
              minimumSize: const Size(0, 56),
              padding: const EdgeInsets.symmetric(horizontal: 48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text(
              'Criar conta gratuita',
              style: GoogleFonts.notoSans(
                  fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/login'),
            style: TextButton.styleFrom(foregroundColor: Colors.white70),
            child: const Text('Já tenho uma conta → Entrar'),
          ),
        ],
      ),
    );
  }

  // ── FOOTER ──────────────────────────────────────────────────────────────────

  Widget _buildFooter(BuildContext context) {
    return Container(
      color: _darkGreen,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.health_and_safety,
                  color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Text(
                'CuidadoIntegrado',
                style: GoogleFonts.notoSans(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Conectando quem cuida a quem precisa de cuidado.',
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSans(
              color: Colors.white54,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ── HELPERS ─────────────────────────────────────────────────────────────────

  Widget _sectionLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: _lightGreen,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.notoSans(
          color: _primaryGreen,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
