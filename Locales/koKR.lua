﻿local L = LibStub("AceLocale-3.0"):NewLocale("Cooldown Buttons","koKR")
if not L then return end

-- Hi Translators, please keep the "Layout" of this file, thanks.

-- configuration
L["Bar Settings"] = "바 설정"
 L["General Settings"] = true
  L["Item to Spells"] = true
  L["Move Items to Spells Cooldown Bar"] = true
 L["Spells"] = "주문"
 L["Items"] = "아이템"
 L["Expiring"] = "완료"
 L["Saved"] = "저장"
 L["HoTs/DoTs"] = true
  L["Position"] = "위치"
   L["Show Anchor"] = "앵커 보기"
   L["Hide Anchor"] = "앵커 숨김"
   L["Disable"] = "비활성화"
   L["Disable this Buttonbar."] = "해당 버튼바를 비활성화 합니다."
   L["X - Axis"] = "X - 축"
   L["Set the Position on X-Axis."] = "X - 축의 위치를 설정합니다."
   L["Y - Axis"] = "Y - 축"
   L["Set the Position on Y-Axis."] = "Y - 축의 위치를 설정합니다."
  L["Alpha & Scale"] = "투명도 & 크기"
   L["Button Scale"] = "버튼 크기"
   L["Set the Button scaling."] = "버튼 크기를 설정합니다."
   L["Button Alpha"] = "버튼 투명도"
   L["Set the Button transparency."] = "버튼 투명도를 설정합니다."
  L["Layout"] = "레이아웃"
   L["Max Buttons"] = "최대 버튼"
   L["Maximal number of Buttons to display."] = "표시할 버튼의 최대 수를 설정합니다."
   L["Direction"] = "방향"
   L["Direction from Anchor."] = "앵커에서 방향"
   L["Center from Anchor"] = "앵커를 중앙"
   L["Toggle Anchor to be the Center of the bar."] = "바의 중앙에 앵커를 둡니다."
   L["If you enable the \"Center from Anchor\" you can set \"Direction\" to Up/Down for vertical and Left/Right for horizontal grow."] = "\"앵커를 중앙\"을 사용한다면, 세로인 위/아래, 가로인 좌/우로 성장방향을 \"방향\"에서 설정할 수 있습니다."
  L["Multi Row Layout"] = "다중 열 레이아웃"
   L["Use Multirow"] = "다중 열 사용"
   L["Toggle useing Multirow."] = "다중 열 사용을 전환합니다."
   L["Max Buttons per Row"] = "최대 버튼 퍼센트 열"
   L["Maximal number of Buttons per Row to display."] = "버튼 퍼센트 열로 표시할 최대수입니다."
--   L["Direction"] = true      -- Already set!
   L["Direction from primary Row."] = "첫째 열에서 방향"
  L["Spacing"] = "간격"
   L["Button Spacing"] = "버튼 간격"
   L["Set the spacing between Buttons."] = "버튼 사이의 간격을 설정합니다."
   L["Row Spacing"] = "열 간격"
   L["Set the spacing between Rows."] = "열 간격을 설정합니다."
   L["Timer Settings"] = "타이머 설정"
 L["Timer Style"] = "타이머 모양"
  L["Show Time"] = "시간 보기"
   L["Toggle showing Cooldown Time at the Buttons."] = "버튼에 재사용 대기시간 시간 표시를 전환합니다."
   L["Style"] = "모양"
   L["Set how the Timertext should look like."] = "타이머문자"
  L["Extras"] = "기타"
   L["Enable OmniCC Settings (Req. OCC >= 2.1.1)"] = "OmniCC 설정 사용 (OCC >= 2.1.1 필요)"
   L["Switch to OmniCC settings."] = "OmniCC 설정 사용을 전환합니다."
   L["The following Options are only aviable if OmniCC Settings are disabled for this Bar."] = "다음의 옵션은 OmniCC 설정을 비활성화된 경우에만 적용됩니다."
   L["Show Cooldown Spiral"] = "나선형 재사용 표시 보기"
   L["Toggle showing Cooldown Spiral on the Buttons."] = "버튼의 나선형 재사용 표시를 전환합니다."
   L["Enable Pulse Effect"] = "맥박 효과 사용"
   L["Toggle Pulse effect."] = "맥박 효과를 전환합니다."
  L["Text Position"]= "문자 위치"
   L["Text Spacing"] = "문자 간격"
   L["Set the spacing between Button and Text."] = "버튼과 문자의 간격을 설정합니다."
   L["Position"] = "위치"
   L["Position from Button."] = "버튼에서 위치"
 L["Font Settings"] = "글꼴 설정"
  L["Font Layout"] = "글꼴 레이아웃"
   L["Font Face"] = "글꼴 모양"
   L["Set the Font type."] = "글꼴 모양을 설정합니다."
   L["Font size"] = "글꼴 크기"
   L["Set the Font size."] = "글꼴 크기를 설정합니다."
  L["Alpha"]= "투명도"
   L["Text Alpha"] = "문자 투명도"
   L["Set the Text transparency."] = "문자의 투명도를 설정합니다."
  L["Font Color"] = "글꼴 색상"
   L["Default Font Color"] = "기본 글꼴 색상"
   L["Set the default Font color."] = "초기값의 글꼴 색상으로 설정합니다."
  L["Flashing Font"] = "깜빡임 글꼴"
   L["Enable flashing Color"] = "깜빡임 색상 사용"
   L["Toggle flashing Color."] = "깜빡임 색상을 전환합니다."
   L["Start Time"] = "시작 시간"
   L["Time when the flashing should start (in seconds)."] = "깜빡임을 시작할 시간(초단위)입니다."
   L["Flash Color 1"] = "깜빡임 색상 1"
   L["Set the flash Font color 1."] = "깜빡임 글꼴 색상 1을 설정합니다."
   L["Flash Color 2"] = "깜빡임 색상 2"
   L["Set the flash Font color 2."] = "깜빡임 글꼴 색상 2를 설정합니다."
  L["Time Limit"] = true
   L["Enable Time Limit"] = true
   L["Toggle hiding long Cooldowns."] = true
   L["Show after Limit"] = true
   L["Toggle showing the Cooldowns after passing the Limit."] = true
   L["Limit (in seconds)"] = true
   L["Maximum Cooldown duration to show (in seconds)."] = true

L["Announcements Settings"] = "알림 설정"
 L["Announcement"] = "알림"
  L["Announcement Message"] = "알림 메세지"
   L["Cooldown on $cooldown ready!"] = "$cooldown 재사용 준비!"
   L["Use \'$cooldown\' to add Cooldown name."] = "재사용 대기시간 이름 추가는 \'$cooldown\' 사용."
   L["Default Message: "] = "메세지 초기값: "
   L["Announcement Area"] = "알림 영역"

L["Cooldown Settings"] = "재사용 대기시간 설정"
 L["Save or Hide"] = "재사용 대기시간 저장"
  L["Spells"] = "주문"
  L["Items"] = "아이템"
  L["Spelltree: "] = true
   L["Hide Button"] = true
   L["Save Button Position"] = "버튼 위치 저장"
   L["Here you can Setup at what position the Cooldown Button for the selected Spell should be drawn to."] = "여기서 따로 빼낸 선택한 주문의 재사용 대기시간 버튼의 위치를 설정할 수 있습니다."
   L["Show Movable Button"] = "이동 버튼 보기"
   L["Hide Movable Button"] = "이동 버튼 숨김"


-- Directions
L["Up"]    = "위"
L["Down"]  = "아래"
L["Left"]  = "좌측"
L["Right"] = "우측"
L["Above"] = "상단"
L["Below"] = "하단"
L["Right - Down"] = "우측 - 아래"
L["Right - Up"]   = "우측 - 위"
L["Left - Down"]  = "좌측 - 아래"
L["Left - Up"]    = "좌측 - 위"


-- Grouping 
L["Healing/Mana Potions"] = "치유/마나 물약"
L["Other Potions"] = "다른 물약"
L["Drums (Leatherworking)"] = "북소리 (가죽세공)"
L["Healthstone"] = "생명석"
L["Spellgroup: Divine Shields"] = "주문그룹: 천상의 보호막"
L["Spellgroup: Shocks"] = "주문그룹: 충격"
L["Spellgroup: Traps"] = "주문그룹: 덫"
