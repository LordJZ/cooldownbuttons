﻿local L = LibStub("AceLocale-3.0"):NewLocale("CoolDown Buttons","koKR")
if not L then return end

-- core.lua
L["Click to Move"] = "이동: 드래그"
L["RemainingCoolDown"] = "$spell 의 재사용 대기간이 $time 남았습니다."

L["Spellgroup: Shocks"] = "주문그룹: 충격"
L["Earth Shock"] = "대지 충격"
L["Flame Shock"] = "화염 충격"
L["Frost Shock"] = "냉기 충격"
L["Spellgroup: Traps"] = "주문그룹: 덫"
L["Freezing Trap"] = "얼음의 덫"
L["Frost Trap"] = "냉기의 덫"
L["Immolation Trap"] = "제물의 덫"
L["Snake Trap"] = "뱀 덫"
L["Explosive Trap"] = "폭발의 덫"

L["Click to Post Cooldown"] = "재사용 대기시간을 알림: 클릭"


-- config.lua
L["Display Settings"] = "디스플레이 설정"
L["Direction"] = "방향"
L["Direction from Anchor"] = "앵커에서 방향"


L["Split Item Cooldowns"] = "아이템 재사용 대기시간 사용"
L["Toggle showing Item and Spell Cooldowns as own rows or not."] = "자신의 주문이 아닌것과 아이템의 재사용 대기시간을 추가된 열에 보여줍니다."
L["Split expiring Cooldown"] = "잠시후 완료 사용"
L["Toggle showing Item and Spell Cooldowns in an additional row if they are expiring soon."] = "잠시후 완료될 경우의 아이템과 주문의 재사용 대기시간을 추가된 열에 보여줍니다."
L["Spell Cooldowns"] = "주문 재사용 대기시간"
L["Item Cooldowns"] = "아이템 재사용 대기시간"
L["Seperated Cooldowns"] = "분리된 재사용 대기시간"

L["Show Anchor"] = "앵커 보이기"
L["Toggle showing Anchor."] = "앵커를 보여줍니다."
L["Max Buttons"] = "최대 버튼"
L["Maximal number of Buttons to display."] = "표시할 버튼의 최대 수를 설정합니다."
L["Button Scale"] = "버튼 크기"
L["Button scaling, this lets you enlarge or shrink your Buttons."] = "버튼 크기, 이것은 버튼을 확대하거나 축소시킵니다."
L["Button Alpha"] = "버튼 투명도"
L["Icon alpha value, this lets you change the transparency of the Button."] = "아이콘의 투명도 값, 이것은 버튼의 투명도를 바꿉니다."


L["Test Mode"] = "테스트 모드"
L["Cancle Test"] = "테스트 취소"
L["Time to show Buttons"] = "버튼을 표시할 시간"
L["Test All"] = "모두 테스트"
L["Test Spells"] = "주문 테스트"
L["Test Items"] = "아이템 테스트"
L["Test expiring Soon"] = "잠시후 완료 테스트"
L["Test Single"] = "고정된 고유 테스트"

L["Posting Settings"] = "알림 설정"
L["Post to:"] = "출력할 곳:"
L["Enable Chatpost"] = "대화창 알림 사용"
L["Toggle posting to Chat."] = "여기에 알림"
L["Set the Text to post."] = "출력 텍스트를 설정합니다."

L["Message Settings"] = "메세지 설정"
L["Use default Message"] = "기본 메세지 사용"
L["Toggle posting the default Message."] = "기본 메세지를 알립니다."
L["Custom Message"] = "사용자 메세지"
L["Set the Text to post."] = "출력할 문자를 입력합니다."
L["The default message is: |cFFFFFFFF$RemainingCoolDown|r"] = "기본 메세지: |cFFFFFFFF$RemainingCoolDown|r"
L["Use |cFFFFFFFF$spell|r for spell name and |cFFFFFFFF$time|r for cooldowntime."] = "|cFFFFFFFF$spell|r 은 주문 이름 , |cFFFFFFFF$time|r 은 재사용 대기 시간 입니다."
L["If \'|cFFFFFFFF$defaultmsg|r\' is disabled use the following Text"] = "만약 \'|cFFFFFFFF$defaultmsg|r\' 을 비활성화 할 경우, 하단에 사용할 알림글을 입력하세요."

L["Up"]    = "위"
L["Down"]  = "아래"
L["Left"]  = "좌측"
L["Right"] = "우측"

L["Above"] = "상단" 
L["Below"] = "하단"
L["Font"] = "글꼴"

L["Use Text Settings"] = "텍스트 설정 사용"
L["Show Time"] = "시간 보기"
L["Toggle showing Cooldown Time at the Buttons."] = "버튼에 재사용 대기 시간의 표시를 설정합니다."
L["Toggle using extra Text Settings."] = "기타적인 텍스트 설정을 사용합니다."
L["Text Side"] = "텍스트 측면"
L["Text Side from Button"] = "버튼에서 텍스트 측면"
L["Text Scale"] = "텍스트 크기"
L["Text scaling, this lets you enlarge or shrink your Text."] = "텍스트 크기, 이것은 텍스트를 확대하거나 축소시킵니다."
L["Text Alpha"] = "텍스트 투명도"
L["Text alpha value, this lets you change the transparency of the Text."] = "텍스트의 투명도 값, 이것은 텍스트의 투명도를 바꿉니다."
L["Button Padding"] = "버튼 간격"
L["Space Between Buttons."] = "버튼사이의 공간을 설정합니다."
L["Text Distance"] = "텍스트 간격"
L["Distance of Text to Button."] = "버튼과 텍스트의 간격을 설정합니다."
L["Show X seconds before ready"] = "준비되기 X 초전에 보기"
L["Sets the time in seconds when the Cooldown should switch to this bar."] = "재사용 대기시간이 설정한 시간에 맞추어 잠시후 완료 버튼으로 전환됩니다."
L["Expiring soon"] = "잠시후 완료"

L["Default Chatframe"] = "기본 대화창"
L["Say"]     = "일반"
L["Party"]   = "파티"
L["Raid"]    = "공격대"
L["Guild"]   = "길드"
L["Officer"] = "길드관리자"
L["Emote"] = "감정 표현"
L["Raidwarning"] = "공격대경보"
L["Battleground"] = "전장"
L["Yell"] = "외침"
L["Custom Channels:"] = "사용자 채널:"
L["Note: Click on a Cooldown Button to post the remaining time to the above selectet Chats."] = "주의: 선택한 채팅창에 남은 시간을 출력하기 위해서는 재사용 대기시간 버튼을 클릭하셔야 됩니다."

L["Default"] = "기본값"
L["Char:"] = "캐릭터:"
L["Realm:"] = "서버:"
L["Class:"] = "직업:"
L["Profiles"] = "프로필"
L["Manage Profiles"] = "프로필 설정"
L["You can change the active profile of CoolDown Buttons, so you can have different settings for every character"] = "모든 캐릭터의 다양한 설정과 사용중인 CoolDown Buttons의 프로필, 어느것이던지 매우 다루기 쉽게 바꿀수 있습니다."
L["Reset the current profile back to its default values, in case your configuration is broken, or you simply want to start over."] = "단순히 다시 새롭게 구성을 원하는 경우, 현재 프로필을 기본값으로 초기화 합니다."
L["Reset Profile"] = "프로필 초기화"
L["Reset the current profile to the default"] = "현재 프로필을 기본값으로 초기화 합니다."
L["You can create a new profile by entering a new name in the editbox, or choosing one of the already exisiting profiles."] = "새로운 이름을 입력하거나, 이미 있는 프로필중 하나를 선택하여 새로운 프로필을 만들 수 있습니다."
L["New"] = "새 프로필"
L["Create a new empty profile."] = "새로운 프로필을 만듭니다."
L["Current"] = "선택"
L["Select one of your currently available profiles."] = "현재 가능한 프로필 중 하나를 선택합니다."
L["Delete existing and unused profiles from the database"] = "데이터베이스에서 사용하지 않는 프로필을 삭제합니다."
L["Delete a Profile"] = "프로필 삭제"
L["Deletes a profile from the database."] = "데이터베이스의 프로필을 삭제합니다."
L["Are you sure you want to delete the selected profile?"] = "정말로 선택한 프로필의 삭제를 원하십니까?"

L["Cooldown Settings"] = "재사용 대기시간 설정"
L["Max Spell Duration"] = "최대 주문 시간"
L["Maximal Duration to show a Spell."] = "표시할 주문의 최대 시간을 설정합니다."
L["Max Item Duration"] = "최대 아이템 시간"
L["Maximal Duration to show a Item."] = "표시할 아이템의 최대 시간을 설정합니다."
L["Show Spells later"] = "주문 시전후 보기"
L["Toggle Spells to display after remaining duration is below max duration."] = "최대 주문 시간의 설정에 맞추어 주문이 남은 시간이 되었을 때 표시합니다."
L["Show Items later"] = "아이템 사용후 보기"
L["Toggle Item to display after remaining duration is below max duration."] = "최대 아이템 시간의 설정에 맞추어 아이템이 남은 시간이 되었을 때 표시합니다."
L["Spell Positions"] = "주문 위치"
L["Hide Spells"] = "주문 숨김"
L["Item Positions"] = "아이템 위치"
L["Hide Items"] = "아이템 숨김"
L["|cFFFFFFFFNote: The X and Y Axis are relative to your bottomleft screen cornor.|r"] = "|cFFFFFFFF주의: X 와 Y 축은 좌측-하단 화면 구석에 비례합니다.|r"
L["Save |cFFFFFFFF$obj|r to a consistent Position"] = "|cFFFFFFFF$obj|r의 고정 위치 저장"
L["Toggle saving of |cFFFFFFFF$obj|r."] = "|cFFFFFFFF$obj|r 고유의 고정적으로 나타낼 위치를 저장합니다."
L["X - Axis"] = "X - 축"
L["Set the Position on X-Axis."] = "X - 축의 위치를 설정합니다."
L["Y - Axis"] = "Y - 축"
L["Set the Position on Y-Axis."] = "Y - 축의 위치를 설정합니다."
L["Move"] = "이동" 
L["Stop"] = "잠금"
L["Show |cFFFFFFFF$obj|r"] = "|cFFFFFFFF$obj|r 보기"
L["Toggle to display |cFFFFFFFF$obj|r's CoolDown."] = "|cFFFFFFFF$obj|r의 재사용 대기시간 표시"

-- itemgroups.lua
L["Healing Potions"] = "치유 물약"
L["Mana Potions"] = "마나 물약"
L["Other Potions"] = "기타 물약"
L["Drums (Leatherworking)"] = "북(가죽세공)"
L["Healthstone"] = "생명석"
