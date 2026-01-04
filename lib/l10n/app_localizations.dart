import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Home
      'appTitle': 'Bravia Remote',
      'noTvConfigured': 'No TV Configured',
      'tapToConnect': 'Tap to connect to your Sony TV',
      'connectToTv': 'Connect to TV',

      // Settings
      'tvSettings': 'TV Settings',
      'save': 'Save',
      'easySetup': 'Easy Setup (Recommended)',
      'setupInstructions': '1. Make sure phone and TV are on same WiFi\n2. Enter your TV\'s IP address\n3. Tap "Pair with PIN"\n4. Enter the 4-digit code shown on TV',
      'autoDiscover': 'Auto Discover',
      'tvName': 'TV Name',
      'tvIpAddress': 'TV IP Address',
      'pleaseEnterName': 'Please enter a name',
      'pleaseEnterIp': 'Please enter IP address',
      'invalidIpFormat': 'Invalid IP address format',
      'pinPairing': 'PIN Pairing',
      'paired': 'Paired',
      'pairWithPin': 'Pair with PIN',
      'rePair': 'Re-pair',
      'enterPin': 'Enter the 4-digit PIN',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'or': 'OR',
      'usePsk': 'Use Pre-Shared Key (Advanced)',
      'pskInstructions': 'If PIN pairing doesn\'t work, you can use PSK:\n1. TV Settings > Network > IP Control\n2. Set Authentication to "Pre-Shared Key"\n3. Enter a password and use it below',
      'preSharedKey': 'Pre-Shared Key (PSK)',
      'testConnection': 'Test Connection',
      'testing': 'Testing...',
      'saveSettings': 'Save Settings',
      'howToFindIp': 'How to find TV IP address',
      'findIpInstructions': '1. Go to TV Settings\n2. Select Network > Network Status\n3. Look for "IP Address"\n\nCommon format: 192.168.x.x',
      'pleaseEnterIpFirst': 'Please enter TV IP address first',
      'checkTvPin': 'Check your TV! Enter the 4-digit PIN shown.',
      'failedStartPairing': 'Failed to start pairing. Check TV IP and try again.',
      'pleasePairOrPsk': 'Please pair with PIN or enter PSK',
      'pairedSuccessfully': 'Paired successfully!',
      'wrongPin': 'Wrong PIN. Please try again.',
      'connectedSuccessfully': 'Connected successfully!',
      'connectionFailed': 'Connection failed',
      'pleasePairFirst': 'Please pair with PIN or enter PSK first',

      // Remote
      'commandFailed': 'Command failed',
      'cannotConnectToTv': 'Cannot connect to TV. Check IP and PSK.',
      'volumeShort': 'VOL',
      'channelShort': 'CH',

      // Text Input
      'textInput': 'Text Input',
      'howToUse': 'How to use',
      'textInputInstructions': '1. Open a search box or text field on your TV\n2. Type your text below\n3. Press Send',
      'enterTextToSend': 'Enter text to send...',
      'sendToTv': 'Send to TV',
      'recent': 'Recent',
      'sentTextsAppearHere': 'Sent texts will appear here',
      'textSentSuccessfully': 'Text sent successfully',
      'failedToSendText': 'Failed to send text. Make sure a text field is active on TV.',

      // Discovery
      'scanning': 'Scanning for BRAVIA TVs...',
      'scanFailed': 'Scan failed. Please try again.',
      'tryAgain': 'Try Again',
      'noDevicesFound': 'No devices found.',
      'rescan': 'Rescan',
      'sameWifiHint': 'Make sure your phone and TV are on the same Wi-Fi.',

      // Theme
      'theme': 'Theme',
      'lightTheme': 'Light',
      'darkTheme': 'Dark',
      'language': 'Language',

      // Features
      'featureRemoteControl': 'Full Remote Control',
      'featureTextInput': 'Text Input for Search',
      'featureQuickApps': 'Quick App Launch',
    },
    'zh': {
      // 首页
      'appTitle': 'Bravia 遥控器',
      'noTvConfigured': '未配置电视',
      'tapToConnect': '点击连接你的索尼电视',
      'connectToTv': '连接电视',

      // 设置
      'tvSettings': '电视设置',
      'save': '保存',
      'easySetup': '简易设置（推荐）',
      'setupInstructions': '1. 确保手机和电视在同一 WiFi\n2. 输入电视的 IP 地址\n3. 点击"PIN 配对"\n4. 输入电视上显示的 4 位数字',
      'autoDiscover': '自动发现',
      'tvName': '电视名称',
      'tvIpAddress': '电视 IP 地址',
      'pleaseEnterName': '请输入名称',
      'pleaseEnterIp': '请输入 IP 地址',
      'invalidIpFormat': 'IP 地址格式无效',
      'pinPairing': 'PIN 配对',
      'paired': '已配对',
      'pairWithPin': 'PIN 配对',
      'rePair': '重新配对',
      'enterPin': '输入 4 位 PIN 码',
      'cancel': '取消',
      'confirm': '确认',
      'or': '或者',
      'usePsk': '使用预共享密钥（高级）',
      'pskInstructions': '如果 PIN 配对无法使用，可以使用 PSK：\n1. 电视设置 > 网络 > IP 控制\n2. 将认证设置为"预共享密钥"\n3. 输入密码并在下方使用',
      'preSharedKey': '预共享密钥 (PSK)',
      'testConnection': '测试连接',
      'testing': '测试中...',
      'saveSettings': '保存设置',
      'howToFindIp': '如何查找电视 IP 地址',
      'findIpInstructions': '1. 进入电视设置\n2. 选择网络 > 网络状态\n3. 查找"IP 地址"\n\n常见格式：192.168.x.x',
      'pleaseEnterIpFirst': '请先输入电视 IP 地址',
      'checkTvPin': '请查看电视！输入显示的 4 位 PIN 码。',
      'failedStartPairing': '配对启动失败。请检查电视 IP 并重试。',
      'pleasePairOrPsk': '请先进行 PIN 配对或输入 PSK',
      'pairedSuccessfully': '配对成功！',
      'wrongPin': 'PIN 码错误，请重试。',
      'connectedSuccessfully': '连接成功！',
      'connectionFailed': '连接失败',
      'pleasePairFirst': '请先进行 PIN 配对或输入 PSK',

      // 遥控器
      'commandFailed': '命令失败',
      'cannotConnectToTv': '无法连接到电视。请检查 IP 和 PSK。',
      'volumeShort': '音量',
      'channelShort': '频道',

      // 文本输入
      'textInput': '文本输入',
      'howToUse': '使用方法',
      'textInputInstructions': '1. 在电视上打开搜索框或文本输入框\n2. 在下方输入文字\n3. 点击发送',
      'enterTextToSend': '输入要发送的文字...',
      'sendToTv': '发送到电视',
      'recent': '最近',
      'sentTextsAppearHere': '已发送的文字将显示在这里',
      'textSentSuccessfully': '文字发送成功',
      'failedToSendText': '发送失败。请确保电视上有活动的文本输入框。',

      // 发现
      'scanning': '正在扫描 BRAVIA 电视...',
      'scanFailed': '扫描失败，请重试。',
      'tryAgain': '重试',
      'noDevicesFound': '未发现设备。',
      'rescan': '重新扫描',
      'sameWifiHint': '请确保手机和电视在同一 WiFi 网络。',

      // 主题
      'theme': '主题',
      'lightTheme': '浅色',
      'darkTheme': '深色',
      'language': '语言',

      // 功能特性
      'featureRemoteControl': '完整遥控功能',
      'featureTextInput': '文本输入搜索',
      'featureQuickApps': '快捷应用启动',
    },
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'zh'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
