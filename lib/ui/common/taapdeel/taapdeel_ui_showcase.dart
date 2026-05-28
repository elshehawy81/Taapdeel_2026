import 'package:flutter/material.dart';
import 'package:taapdeel/constant/ps_dimens.dart';
// Taapdeel core components
import 'package:taapdeel/ui/common/taapdeel/taapdeel_app_bar.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_base_dialog.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_button.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_card.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_category_card.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_chip.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_dropdown.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_filter_bar.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_highlight_card.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_highlight_carousel.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_info_card_shell.dart'; // 👈 الجديد
import 'package:taapdeel/ui/common/taapdeel/taapdeel_scaffold.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_section_header.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_side_glass_card.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_tab_bar.dart';
import 'package:taapdeel/ui/common/taapdeel/taapdeel_text_field.dart';

/// شاشة استعراض الـ UI الموحَّد لتاپديل (Design System Playground)
class TaapdeelUiShowcasePage extends StatelessWidget {
  const TaapdeelUiShowcasePage({Key? key}) : super(key: key);

  void _showSampleDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return TaapdeelBaseDialog(
          title: 'تأكيد العملية',
          message: 'هل تريد بالفعل تنفيذ هذه العملية؟ يمكنك التراجع في أي وقت لاحق.',
          icon: Icons.info_rounded,
          primaryButtonLabel: 'تأكيد',
          onPrimaryTap: () {
            Navigator.of(ctx).maybePop();
          },
          secondaryButtonLabel: 'إلغاء',
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return TaapdeelScaffold(
      appBar: const TaapdeelAppBar(
        title: 'Taapdeel UI Showcase',
        centerTitle: true,
        showBackButton: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(PsDimens.space16),
        children: <Widget>[
          // ============================
          // Buttons
          // ============================
          const _SectionTitle('Buttons'),
          const SizedBox(height: PsDimens.space8),
          Wrap(
            spacing: PsDimens.space12,
            runSpacing: PsDimens.space12,
            children: <Widget>[
              TaapdeelButton(
                label: 'Primary',
                isPrimary: true,
                onPressed: () {},
              ),
              TaapdeelButton(
                label: 'Secondary',
                isPrimary: false,
                onPressed: () {},
              ),
              TaapdeelButton(
                label: 'Outlined',
                outlined: true,
                onPressed: () {},
              ),
              TaapdeelButton(
                label: 'Icon + Text',
                isPrimary: true,
                icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                onPressed: () {},
              ),
              TaapdeelButton(
                label: 'Show Dialog',
                isPrimary: true,
                icon: const Icon(Icons.info_outline_rounded, size: 18),
                onPressed: () => _showSampleDialog(context),
              ),
            ],
          ),

          const SizedBox(height: PsDimens.space24),

          // ============================
          // Text Fields
          // ============================
          const _SectionTitle('Text Fields'),
          const SizedBox(height: PsDimens.space8),
          const TaapdeelTextField(
            label: 'عنوان المنتج',
            hint: 'مثال: موبايل سامسونج مستعمل',
            helperText: 'حاول يكون العنوان واضح وجذاب',
          ),
          const SizedBox(height: PsDimens.space12),
          const TaapdeelTextField(
            label: 'بحث',
            hint: 'ابحث عن منتج أو فئة',
            prefixIcon: Icons.search_rounded,
            isSearchField: true,
          ),

          const SizedBox(height: PsDimens.space24),

          // ============================
          // Chips
          // ============================
          const _SectionTitle('Chips'),
          const SizedBox(height: PsDimens.space8),
          Wrap(
            spacing: PsDimens.space8,
            children: const <Widget>[
              TaapdeelChip(
                label: 'إلكترونيات',
                selected: true,
                icon: Icons.devices_other_rounded,
              ),
              TaapdeelChip(
                label: 'أثاث',
                selected: false,
                icon: Icons.chair_alt_rounded,
              ),
              TaapdeelChip(
                label: 'أطفال',
                selected: false,
                icon: Icons.toys_rounded,
                compact: true,
              ),
            ],
          ),

          const SizedBox(height: PsDimens.space24),

          // ============================
          // Category Cards
          // ============================
          const _SectionTitle('Category Cards'),
          const SizedBox(height: PsDimens.space8),
          _PreviewCard(
            child: Padding(
              padding: const EdgeInsets.all(PsDimens.space12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: const <Widget>[
                    TaapdeelCategoryCard(
                      label: 'أطفال',
                      showPlusWhenNoIcon: true,
                    ),
                    SizedBox(width: PsDimens.space12),
                    TaapdeelCategoryCard(
                      label: 'موبايلات',
                      iconImage: AssetImage(
                        'assets/images/icons/phone_3d.png',
                      ),
                    ),
                    SizedBox(width: PsDimens.space12),
                    TaapdeelCategoryCard(
                      label: 'موبيليات',
                      iconImage: AssetImage(
                        'assets/images/icons/fridge_3d.png',
                      ),
                      isSelected: true,
                    ),
                    SizedBox(width: PsDimens.space12),
                    TaapdeelCategoryCard(
                      label: 'أثاث',
                      iconImage: AssetImage(
                        'assets/images/icons/chair_3d.png',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: PsDimens.space24),

          // ============================
          // Filter Bar
          // ============================
          const _SectionTitle('Filter Bar'),
          const SizedBox(height: PsDimens.space8),
          _PreviewCard(
            child: TaapdeelFilterBar<String>(
              items: <String>['الكل', 'إلكترونيات', 'أثاث', 'أطفال'],
              labelBuilder: (String it) => it,
              selectedItems: <String>['إلكترونيات'],
              onSelectionChanged: (List<String> _) {},
            ),
          ),

          const SizedBox(height: PsDimens.space24),

          // ============================
          // Dropdown
          // ============================
          const _SectionTitle('Dropdown'),
          const SizedBox(height: PsDimens.space8),
          _PreviewCard(
            child: Padding(
              padding: const EdgeInsets.all(PsDimens.space12),
              child: TaapdeelDropdown<String>(
                items: <String>['كل المدن', 'القاهرة', 'الإسكندرية', 'الرياض'],
                itemLabelBuilder: (String it) => it,
                value: 'القاهرة',
                onChanged: (String? _) {},
                label: 'المدينة',
                hint: 'اختر المدينة',
                prefixIcon: Icons.location_on_outlined,
              ),
            ),
          ),

          const SizedBox(height: PsDimens.space24),

          // ============================
          // Section Header
          // ============================
          const _SectionTitle('Section Header'),
          const SizedBox(height: PsDimens.space8),
          const _PreviewCard(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: PsDimens.space16),
              child: TaapdeelSectionHeader(
                title: 'العناصر المقترحة لك',
                subtitle: 'استنادًا إلى اهتماماتك الأخيرة',
                actionLabel: 'عرض الكل',
              ),
            ),
          ),

          const SizedBox(height: PsDimens.space24),

          // ============================
          // Taapdeel Card
          // ============================
          const _SectionTitle('Taapdeel Card'),
          const SizedBox(height: PsDimens.space8),
          TaapdeelCard(
            leading: const Icon(Icons.devices_other_rounded),
            title: 'إلكترونيات قريبة منك',
            subtitle: 'أفضل العروض من الجيران في محيطك',
            trailing: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
            ),
            body: Padding(
              padding: const EdgeInsets.only(top: PsDimens.space12),
              child: Wrap(
                spacing: PsDimens.space8,
                runSpacing: PsDimens.space4,
                children: const <Widget>[
                  Chip(
                    label: Text('موبايلات'),
                    visualDensity: VisualDensity.compact,
                  ),
                  Chip(
                    label: Text('لاب توب'),
                    visualDensity: VisualDensity.compact,
                  ),
                  Chip(
                    label: Text('إكسسوارات'),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
            onTap: () {},
          ),
          const SizedBox(height: PsDimens.space12),
          TaapdeelCard(
            title: 'نصيحة',
            subtitle: 'كلما وصفت منتجك بدقة، زادت فرص التبديل الناجح.',
            body: const Padding(
              padding: EdgeInsets.only(top: PsDimens.space8),
              child: Text(
                'استخدم صور واضحة، وحدد حالة المنتج، واكتب تفاصيل صغيرة مثل الملحقات المرفقة.',
              ),
            ),
          ),

          const SizedBox(height: PsDimens.space24),

          // ============================
          // Info Card Shell  (شكل "تبديل" بدون صورة أساسية)
          // ============================
          const _SectionTitle('Info Card Shell'),
          const SizedBox(height: PsDimens.space8),
          //TaapdeelInfoCardShell
          //  (
            //padding: const EdgeInsets.all(20),

         // ),

          const SizedBox(height: PsDimens.space24),

          // ============================
          // Side Glass Card
          // ============================
          const _SectionTitle('Side Glass Card'),
          const SizedBox(height: PsDimens.space8),
          _PreviewCard(
            height: 220,
            child: TaapdeelSideGlassCard(
              backgroundImage:
              const AssetImage('assets/images/placeholder.jpg'),
              title: 'بدّل أغراضك بسهولة مع أصدقاء الحي',
              onTap: () {},
            ),
          ),

          const SizedBox(height: PsDimens.space24),

          // ============================
          // Tabs
          // ============================
          const _SectionTitle('Tab Bar'),
          const SizedBox(height: PsDimens.space8),
          _PreviewCard(
            height: 160,
            child: DefaultTabController(
              length: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TaapdeelTabBar(
                    tabs: const <Widget>[
                      Tab(text: 'الكل'),
                      Tab(text: 'قريب منك'),
                      Tab(text: 'الأكثر نشاطًا'),
                    ],
                  ),
                  const Expanded(
                    child: TabBarView(
                      children: <Widget>[
                        Center(child: Text('محتوى تبويب الكل')),
                        Center(child: Text('محتوى قريب منك')),
                        Center(child: Text('محتوى الأكثر نشاطًا')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: PsDimens.space24),

          // ============================
          // Highlight Card
          // ============================
          const _SectionTitle('Highlight Card'),
          const SizedBox(height: PsDimens.space8),
          _PreviewCard(
            height: 260,
            child: TaapdeelHighlightCard(
              backgroundImage:
              const AssetImage('assets/images/placeholder.jpg'),
              headerTitle: 'عروض مميزة',
              headerIcon: Icons.auto_awesome_rounded,
              label: 'أقوى عروض الأسبوع',
              title: 'بدّل أغراضك القديمة بأشياء تحبها',
              currentDot: 1,
              dotsCount: 3,
              onTap: () {},
            ),
          ),

          const SizedBox(height: PsDimens.space24),

          // ============================
          // Highlight Carousel
          // ============================
          const _SectionTitle('Highlight Carousel'),
          const SizedBox(height: PsDimens.space8),
          _PreviewCard(
            height: 260,
            child: TaapdeelHighlightCarousel(
              items: <TaapdeelHighlightItem>[
                TaapdeelHighlightItem(
                  backgroundImage:
                  const AssetImage('assets/images/placeholder.jpg'),
                  headerTitle: 'Top Picks',
                  headerIcon: Icons.star_rounded,
                  label: 'منتجات مختارة لك',
                  title: 'بدّل مع جيرانك القريبين',
                ),
                TaapdeelHighlightItem(
                  backgroundImage:
                  const AssetImage('assets/images/placeholder.jpg'),
                  headerTitle: 'New',
                  headerIcon: Icons.new_releases_rounded,
                  label: 'انضم لمجتمع التبديل',
                  title: 'ابدأ برفع أول منتج لك اليوم',
                ),
              ],
              enableAutoPlay: false,
            ),
          ),

          const SizedBox(height: PsDimens.space24),

          // ============================
          // Notes
          // ============================
          const _SectionTitle('Notes'),
          const SizedBox(height: PsDimens.space4),
          const Text(
            'هذه الشاشة مخصّصة للمطورين لمراجعة مظهر الـ Design System.\n'
                'يمكنك تعديل الأمثلة أو إضافة أمثلة جديدة لكل Component حسب الحاجة.\n'
                'تذكّر تعديل مسارات الصور AssetImage إلى صور حقيقية موجودة في مشروعك.',
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: PsDimens.space24),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, {Key? key}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    Key? key,
    required this.child,
    this.height,
  }) : super(key: key);

  final Widget child;
  final double? height;

  @override
  Widget build(BuildContext context) {
    const BorderRadius radius = BorderRadius.all(Radius.circular(20));

    return Container(
      margin: const EdgeInsets.only(bottom: PsDimens.space8),
      decoration: const BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xF2FFFFFF),
            Color(0xD9F3FFFE),
          ],
        ),
        border: Border.fromBorderSide(
          BorderSide(
            color: Color(0xE6FFFFFF),
            width: 1.0,
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: SizedBox(
          height: height,
          child: child,
        ),
      ),
    );
  }
}
