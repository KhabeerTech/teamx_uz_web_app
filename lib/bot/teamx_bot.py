import os
import logging
import time
import telebot
import firebase_admin
from firebase_admin import credentials, firestore
from google.cloud import firestore as firestore_timestamp
from telebot import types

# Logging sozlamalari
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    filename='bot.log'
)
logger = logging.getLogger('TeamX_Bot')

# Bot tokenini olish
BOT_TOKEN = '7982094382:AAGm8FIJj0giyIdQDycNtZld_kQdRNnZdlg'

# Firebase-ni ishga tushirish
try:
    cred = credentials.Certificate("serviceAccountKey.json")
    firebase_admin.initialize_app(cred)
    db = firestore.client()
except Exception as e:
    logger.error(f"Firebase initializatsiya xatosi: {str(e)}")
    raise e

# Foydalanuvchi ma'lumotlarini saqlash uchun
user_data = {}
waiting_for_username = {}
waiting_for_password = {}

# Admin IDs
ADMIN_IDS = [123456789, 987654321]  # Admin telegram IDs

def validate_phone(phone):
    """Telefon raqam validatsiyasi"""
    return phone.isdigit() and len(phone) == 9

def validate_username(username):
    """Username validatsiyasi"""
    # Faqat raqamlardan iborat usernameni rad etish
    if username.isdigit():
        return False
    # Kamida bitta harf bo'lishi kerak
    has_letter = any(c.isalpha() for c in username)
    if not has_letter:
        return False
    # Uzunlik va alfanumerik tekshiruvi
    return len(username) >= 4 and username.isalnum()

def validate_password(password):
    """Parol validatsiyasi"""
    return len(password) >= 6

def start_bot():
    try:
        # Bot yaratish
        bot = telebot.TeleBot(BOT_TOKEN)

        # Inline keyboard yaratish
        branch_markup = telebot.types.InlineKeyboardMarkup()
        gijduvon_button = telebot.types.InlineKeyboardButton("G'ijduvon", callback_data='branch_gijduvon')
        qiziltepa_button = telebot.types.InlineKeyboardButton("Qiziltepa", callback_data='branch_qiziltepa')
        branch_markup.add(gijduvon_button, qiziltepa_button)

        @bot.message_handler(commands=['start'])
        def start(message):
            user_id = message.from_user.id
            
            if user_id in user_data:
                del user_data[user_id]
            
            bot.reply_to(message, """
🎓 Team X platformasiga xush kelibsiz!

Team Lead sifatida ro'yxatdan o'tish uchun quyidagi ma'lumotlarni kiriting.

👤 To'liq ismingizni kiriting:
Masalan: Roziqov Farhod""")
            
            bot.register_next_step_handler(message, process_full_name)

        def process_full_name(message):
            user_id = message.from_user.id
            full_name = message.text.strip()
            
            user_data[user_id] = {'full_name': full_name}
            
            bot.reply_to(message, """
📱 Telefon raqamingizni kiriting (9 raqam):
Masalan: 901234567""")
            
            bot.register_next_step_handler(message, process_student_phone)

        def process_student_phone(message):
            user_id = message.from_user.id
            phone = message.text.strip()
            
            if not validate_phone(phone):
                bot.reply_to(message, "❌ Noto'g'ri format! Qayta kiriting (9 raqam):")
                bot.register_next_step_handler(message, process_student_phone)
                return
            
            user_data[user_id]['student_phone'] = phone
            
            bot.reply_to(message, """
📱 Otangizning telefon raqamini kiriting:
Masalan: 901234567""")
            
            bot.register_next_step_handler(message, process_father_phone)

        def process_father_phone(message):
            user_id = message.from_user.id
            phone = message.text.strip()
            
            if not validate_phone(phone):
                bot.reply_to(message, "❌ Noto'g'ri format! Qayta kiriting (9 raqam):")
                bot.register_next_step_handler(message, process_father_phone)
                return
            
            user_data[user_id]['father_phone'] = phone
            
            bot.reply_to(message, """
📱 Onangizning telefon raqamini kiriting:
Masalan: 901234567""")
            
            bot.register_next_step_handler(message, process_mother_phone)

        def process_mother_phone(message):
            user_id = message.from_user.id
            phone = message.text.strip()
            
            if not validate_phone(phone):
                bot.reply_to(message, "❌ Noto'g'ri format! Qayta kiriting (9 raqam):")
                bot.register_next_step_handler(message, process_mother_phone)
                return
            
            user_data[user_id]['mother_phone'] = phone
            
            markup = types.InlineKeyboardMarkup()
            markup.row(
                types.InlineKeyboardButton("Qiziltepa", callback_data="branch_qiziltepa"),
                types.InlineKeyboardButton("Gijduvon", callback_data="branch_gijduvon")
            )
            
            bot.reply_to(message, "🏢 Filiallardan birini tanlang:", reply_markup=markup)

        @bot.callback_query_handler(func=lambda call: call.data.startswith('branch_'))
        def branch_callback(call):
            user_id = call.from_user.id
            branch = call.data.replace('branch_', '')
            
            user_data[user_id]['branch'] = branch
            
            bot.edit_message_text(
                chat_id=call.message.chat.id,
                message_id=call.message.message_id,
                text=f"""
✅ {branch.title()} filiali tanlandi!

📝 Endi o'zingiz uchun username yarating:
- Kamida 4 ta belgi
- Faqat harflar va raqamlar
- Bo'sh joy bo'lmasligi kerak""")
            
            bot.register_next_step_handler(call.message, process_username)

        def process_username(message):
            try:
                username = message.text.strip().lower()
                user_id = message.from_user.id
                
                if not validate_username(username):
                    bot.reply_to(message, """
❌ Username noto'g'ri!
Qayta kiriting:
- Kamida 4 ta belgi
- Faqat harflar va raqamlar
- Bo'sh joy bo'lmasligi kerak""")
                    bot.register_next_step_handler(message, process_username)
                    return
                
                doc = db.collection('users').document(username).get()
                if doc.exists:
                    bot.reply_to(message, "❌ Bu username band! Boshqa username tanlang:")
                    bot.register_next_step_handler(message, process_username)
                    return
                
                user_data[user_id]['username'] = username
                user_data[user_id]['display_username'] = message.text.strip()
                
                bot.reply_to(message, """
🔐 Parol yarating:
- Kamida 6 ta belgi
- Parolni eslab qoling!

Masalan: MyPassword123""")
                bot.register_next_step_handler(message, process_password)
                
            except Exception as e:
                logger.error(f"Error in process_username: {str(e)}")
                bot.reply_to(message, "❌ Xatolik yuz berdi. Qayta urinib ko'ring.")

        def process_password(message):
            try:
                password = message.text.strip()
                user_id = message.from_user.id
                
                if not validate_password(password):
                    bot.reply_to(message, """
❌ Parol talablarga javob bermaydi!
Qayta kiriting (kamida 6 ta belgi):""")
                    bot.register_next_step_handler(message, process_password)
                    return
                
                data = {
                    'telegram_id': str(user_id),
                    'username': user_data[user_id]['username'],
                    'password': password,
                    'display_username': user_data[user_id]['display_username'],
                    'full_name': user_data[user_id]['full_name'],
                    'student_phone': user_data[user_id]['student_phone'],
                    'father_phone': user_data[user_id]['father_phone'],
                    'mother_phone': user_data[user_id]['mother_phone'],
                    'branch': user_data[user_id]['branch'],
                    'role': 'team_lead',
                    'created_at': firestore_timestamp.SERVER_TIMESTAMP,
                    'is_approved': False,
                    'has_credentials': False,
                    'case': 'yes'
                }
                
                doc_ref = db.collection('users').document(user_data[user_id]['username'])
                doc_ref.set(data)
                
                success_message = f"""
✅ Ro'yxatdan o'tdingiz!

Sizning ma'lumotlaringiz:
👤 Username: {user_data[user_id]['username']}
🔑 Parol: {password}

⚠️ Admin tasdiqlamaguncha tizimga kira olmaysiz!
⏳ Admin tasdiqlanishini kuting."""

                bot.reply_to(message, success_message)
                
                admin_message = f"""
👤 Yangi Team Lead:

Ism: {data['full_name']}
Username: {user_data[user_id]['username']}
Tel: {data['student_phone']}

Tasdiqlash uchun:
/approve_{user_data[user_id]['username']}"""
                
                for admin_id in ADMIN_IDS:
                    try:
                        bot.send_message(admin_id, admin_message)
                    except Exception as e:
                        logger.error(f"Error sending to admin {admin_id}: {str(e)}")
                
            except Exception as e:
                logger.error(f"Error in process_password: {str(e)}")
                bot.reply_to(message, "❌ Xatolik yuz berdi. Qayta urinib ko'ring.")

        @bot.message_handler(func=lambda message: message.text.startswith('/approve_'))
        def approve_user(message):
            logger.info(f"Approve command received: {message.text}")
            if message.from_user.id not in ADMIN_IDS:
                logger.warning(f"Unauthorized access attempt by user {message.from_user.id}")
                bot.reply_to(message, "❌ Sizda admin huquqlari yo'q!")
                return

            try:
                display_username = message.text.replace('/approve_', '')
                logger.info(f"Approving user with display_username: {display_username}")
                
                # Find user by display_username
                logger.info("Querying Firestore for user...")
                users = db.collection('users').where('display_username', '==', display_username).limit(1).get()
                user_docs = list(users)
                
                if not user_docs:
                    logger.error(f"User not found with display_username: {display_username}")
                    bot.reply_to(message, f"❌ Foydalanuvchi {display_username} topilmadi!")
                    return
                    
                user_doc = user_docs[0]
                user_data = user_doc.to_dict()
                username = user_doc.id
                
                logger.info(f"Found user: {username}, data: {str(user_data)}")
                
                # Update user status
                logger.info("Updating user status in Firestore...")
                db.collection('users').document(username).update({
                    'is_approved': True,
                    'has_credentials': True
                })
                logger.info(f"Updated user status for {username}")
                
                # Send message to user
                try:
                    if 'telegram_id' not in user_data:
                        logger.error(f"No telegram_id found for user {username}")
                        bot.reply_to(message, f"❌ Foydalanuvchi {display_username} uchun telegram_id topilmadi!")
                        return
                        
                    logger.info(f"Preparing message for user {username} with telegram_id {user_data['telegram_id']}")
                    user_message = f"""
🎉 Tabriklaymiz {user_data['full_name']}!

Sizning Team Lead sifatidagi arizangiz tasdiqlandi.
Tizimga kirishingiz mumkin.

Tizimga kirish ma'lumotlaringiz:
👤 Username: {username}
🔑 Parol: {user_data['password']}"""
                    
                    logger.info(f"Sending message to user {username} with telegram_id {user_data['telegram_id']}")
                    bot.send_message(user_data['telegram_id'], user_message)
                    logger.info(f"Successfully sent message to user {username}")
                    
                except Exception as e:
                    logger.error(f"Error sending message to user {username}: {str(e)}")
                    bot.reply_to(message, f"❌ Foydalanuvchiga xabar yuborishda xatolik: {str(e)}")
                    return
                
                bot.reply_to(message, f"✅ Foydalanuvchi {display_username} tasdiqlandi!")
                
            except Exception as e:
                logger.error(f"Error in approve_user: {str(e)}")
                bot.reply_to(message, f"❌ Xatolik yuz berdi: {str(e)}")

        logger.info("Bot started")
        bot.infinity_polling()

    except Exception as e:
        logger.error(f"Bot ishga tushishida xatolik: {e}")

if __name__ == '__main__':
    start_bot()
