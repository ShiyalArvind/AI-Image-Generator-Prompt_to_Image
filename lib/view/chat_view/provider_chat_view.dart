import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Common/custom_text.dart';
import '../../auth/login_page.dart';
import '../../model/chat_message.dart';
import '../../provider/auth_provider.dart';
import '../../provider/chat_provider.dart';
import '../../utils/color_file.dart';
import '../../utils/constant_file.dart';
import '../../utils/responsive.dart';
import '../../utils/string_file.dart';
import 'slider.dart';
import 'chat_time_line.dart';
import 'message_bar.dart';

class GenericChatView extends StatefulWidget {
  const GenericChatView({super.key, required this.fetchMessages, required this.getMessages, required this.footerBuilder});

  final Future<void> Function(BuildContext) fetchMessages;
  final List<ChatMessage> Function(ChatProvider) getMessages;
  final Widget Function(BuildContext, ChatProvider) footerBuilder;

  @override
  State<GenericChatView> createState() => _GenericChatViewState();
}

class _GenericChatViewState extends State<GenericChatView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController textController = TextEditingController();
  final Duration _scrollDelay = const Duration(seconds: 1);

  void _removeInputTextFocus() => FocusScope.of(context).unfocus();

  Future<bool> _onPageTopScrollFunction() async {
    await Future.delayed(_scrollDelay);
    return true;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(0.0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ensures it runs every time the widget is inserted in the tree
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.fetchMessages(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: ChatTheme.chatBackgroundDecoration,
        child: ResponsiveBuilder(
          builder: (context, res) {
            return Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _removeInputTextFocus,
                    child: Consumer<ChatProvider>(
                      builder: (context, chatProvider, _) {
                        final messages = widget.getMessages(chatProvider);
                        final isFetched = chatProvider.isLoading;
                        if (isFetched) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (messages.isEmpty) {
                          return Center(
                            child: CustomText(
                              StringFile.noMessage,
                              color: ColorFile.blackColor,
                              fontSize: ConstantsFile.largeFontSize,
                              fontFamily: ConstantsFile.semiBoldFont,
                            ),
                          );
                        }

                        return ChatTimeline(
                          messages: messages,
                          localUserTheme: ChatTheme.localUserTheme(context),
                          remoteUserTheme: ChatTheme.remoteUserTheme(context),
                          onPageTopScrollFunction: _onPageTopScrollFunction,
                          scrollController: _scrollController,
                        );
                      },
                    ),
                  ),
                ),
                Consumer<ChatProvider>(
                  builder: (context, chatProvider, _) {
                    return MessageBar(
                      footerWidget: widget.footerBuilder(context, chatProvider),
                      onSend: (text) {
                        if (text.trim().isEmpty) return;
                        final provider = context.read<ChatProvider>();

                        provider.sendImagePrompt(text, provider.imageQuantity, provider.imageQuality.toInt(), isSender: true);

                        Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
                        textController.clear();
                      },
                      actions: [
                        InkWell(child: Icon(Icons.add, color: ColorFile.blackColor, size: res.width(24)), onTap: () {}),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: res.width(8)),
                          child: InkWell(
                            child: Icon(Icons.camera_alt, color: ColorFile.greenColor, size: res.width(24)),
                            onTap: () {},
                          ),
                        ),
                      ],
                      textController: textController,
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class ProviderImageView extends StatelessWidget {
  const ProviderImageView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: ColorFile.primaryColor,
          centerTitle: true,
          title: CustomText(
            StringFile.imageGenerator,
            color: ColorFile.whiteColor,
            fontSize: ConstantsFile.largeFontSize,
            fontFamily: ConstantsFile.semiBoldFont,
          ),
          actions: [
            IconButton(
              onPressed: () {
                context.read<AuthProvider>().signOut();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
              },
              icon: const Icon(Icons.logout_sharp,color: ColorFile.whiteColor,)),
          ],
        ),
        body: GenericChatView(
          fetchMessages: (ctx) => ctx.read<ChatProvider>().getAllImages(),
          getMessages: (provider) => provider.getImages(),
          footerBuilder: (ctx, provider) => _buildImageQualityAndQuantityControls(provider),
        ),
      ),
    );
  }

  Widget _buildImageQualityAndQuantityControls(ChatProvider chatProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                CustomRangeSlider(
                  values: chatProvider.imageQuality,
                  min: 0.0,
                  max: 50.0,
                  onChanged: chatProvider.updateImageQuality,
                ),
                const SizedBox(height: 5),
                CustomText(
                  "${StringFile.imageQuality}: ${chatProvider.imageQuality.toStringAsFixed(0)} ",
                  color: ColorFile.blackColor,
                  fontSize: ConstantsFile.regularFontSize,
                  fontFamily: ConstantsFile.mediumFont,
                ),
              ],
            ),
            Column(
              children: [
                Row(
                  children: [
                    IconButton(icon: const Icon(Icons.remove), onPressed: chatProvider.decrementImageQty),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Text(chatProvider.imageQuantity.toString()),
                    ),
                    IconButton(icon: const Icon(Icons.add), onPressed: chatProvider.incrementImageQty),
                  ],
                ),
                const SizedBox(height: 10),
                CustomText(
                  StringFile.imageCreateCount,
                  color: ColorFile.blackColor,
                  fontSize: ConstantsFile.regularFontSize,
                  fontFamily: ConstantsFile.mediumFont,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
