import 'package:currency_converter/core/di/injectable_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
 import 'package:currency_converter/core/utils/colors.dart';
import 'package:currency_converter/features/currency/domain/entities/currency.dart';
import 'package:currency_converter/features/currency/presentation/bloc/bloc.dart';
import '../widgets/currency_search_field.dart';
import '../widgets/currency_list_item.dart';
import '../widgets/currency_section_header.dart';

/// Page for selecting a currency from a list.
///
/// This page uses [CurrencyBloc] to fetch currencies from the API
/// and display them. It follows the offline-first approach.
class CurrencyPickerPage extends StatefulWidget {
  const CurrencyPickerPage({
    super.key,
    this.selectedCurrencyCode,
    this.onCurrencySelected,
  });

  /// The currently selected currency code.
  final String? selectedCurrencyCode;

  /// Callback when a currency is selected.
  final ValueChanged<Currency>? onCurrencySelected;

  @override
  State<CurrencyPickerPage> createState() => _CurrencyPickerPageState();
}

class _CurrencyPickerPageState extends State<CurrencyPickerPage> {
  final TextEditingController _searchController = TextEditingController();
  late final CurrencyBloc _currencyBloc;

  @override
  void initState() {
    super.initState();
    _currencyBloc = getIt<CurrencyBloc>();
    // Load currencies when page opens
    _currencyBloc.add(const LoadCurrencies());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _currencyBloc.close();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _currencyBloc.add(SearchCurrencies(value));
  }

  void _onCurrencyTapped(Currency currency) {
    widget.onCurrencySelected?.call(currency);
    Navigator.of(context).pop(currency);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _currencyBloc,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: _buildAppBar(),
        body: SafeArea(
          child: Column(
            children: [
              // Search field
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                child: CurrencySearchField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                ),
              ),
              // Currency list
              Expanded(
                child: BlocBuilder<CurrencyBloc, CurrencyState>(
                  builder: (context, state) {
                    return switch (state) {
                      CurrencyInitial() => const SizedBox.shrink(),
                      CurrencyLoading() => _buildLoadingState(),
                      CurrencyError(:final message) =>
                        _buildErrorState(message),
                      CurrencyLoaded() => _buildCurrencyList(state),
                    };
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.backgroundLight,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_rounded,
          color: AppColors.textPrimary,
          size: 20,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      centerTitle: true,
      title: Text(
        'Select Currency',
        style: TextStyle(
          fontSize: 18.dp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      actions: [
        // Refresh button
        BlocBuilder<CurrencyBloc, CurrencyState>(
          builder: (context, state) {
            if (state is CurrencyLoaded && state.isFromCache) {
              return IconButton(
                icon: Icon(
                  Icons.refresh_rounded,
                  color: AppColors.cyan,
                  size: 24,
                ),
                onPressed: () {
                  _currencyBloc.add(const RefreshCurrencies());
                },
                tooltip: 'Refresh currencies',
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.cyan,
            strokeWidth: 3,
          ),
          SizedBox(height: 2.h),
          Text(
            'Loading currencies...',
            style: TextStyle(
              fontSize: 14.dp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppColors.error,
            ),
            SizedBox(height: 2.h),
            Text(
              'Failed to load currencies',
              style: TextStyle(
                fontSize: 16.dp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.dp,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 3.h),
            ElevatedButton.icon(
              onPressed: () {
                _currencyBloc.add(const LoadCurrencies());
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cyan,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyList(CurrencyLoaded state) {
    final showSearchResults = state.searchQuery.isNotEmpty;
    final currencies = state.displayCurrencies;
    final popularCurrencies = state.popularCurrencies;

    // If searching, show flat list of results
    if (showSearchResults) {
      if (currencies.isEmpty) {
        return _buildEmptyState();
      }

      return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        itemCount: currencies.length + 1, // +1 for header
        itemBuilder: (context, index) {
          if (index == 0) {
            return CurrencySectionHeader(
              title: '${currencies.length} RESULTS',
            );
          }
          final currency = currencies[index - 1];
          return Padding(
            padding: EdgeInsets.only(bottom: 1.5.h),
            child: CurrencyListItem(
              currencyCode: currency.code,
              currencyName: currency.name,
              flagUrl: currency.flagUrl,
              isSelected: currency.code == widget.selectedCurrencyCode,
              onTap: () => _onCurrencyTapped(currency),
            ),
          );
        },
      );
    }

    // Show categorized list (Popular + All)
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      children: [
        // Popular section
        if (popularCurrencies.isNotEmpty) ...[
          const CurrencySectionHeader(title: 'POPULAR'),
          ...popularCurrencies.map(
            (currency) => Padding(
              padding: EdgeInsets.only(bottom: 1.5.h),
              child: CurrencyListItem(
                currencyCode: currency.code,
                currencyName: currency.name,
                flagUrl: currency.flagUrl,
                isSelected: currency.code == widget.selectedCurrencyCode,
                onTap: () => _onCurrencyTapped(currency),
              ),
            ),
          ),
        ],
        // All currencies section
        if (currencies.isNotEmpty) ...[
          SizedBox(height: 1.h),
          CurrencySectionHeader(title: 'ALL CURRENCIES (${currencies.length})'),
          ...currencies.map(
            (currency) => Padding(
              padding: EdgeInsets.only(bottom: 1.5.h),
              child: CurrencyListItem(
                currencyCode: currency.code,
                currencyName: currency.name,
                flagUrl: currency.flagUrl,
                isSelected: currency.code == widget.selectedCurrencyCode,
                onTap: () => _onCurrencyTapped(currency),
              ),
            ),
          ),
        ],
        SizedBox(height: 2.h),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: AppColors.textMuted,
            ),
            SizedBox(height: 2.h),
            Text(
              'No currencies found',
              style: TextStyle(
                fontSize: 16.dp,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Try a different search term',
              style: TextStyle(
                fontSize: 14.dp,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
