from flask import Flask, request, jsonify
from flask_cors import CORS
import anthropic
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

app = Flask(__name__)

# CORS configuratie - breed genoeg voor alle browsers en lokale testing
CORS(app, resources={
    r"/*": {
        "origins": ["*"],
        "methods": ["GET", "POST", "OPTIONS"],
        "allow_headers": ["Content-Type", "Authorization"],
        "expose_headers": ["Content-Type"],
        "supports_credentials": False,
        "max_age": 3600
    }
})

# Initialize Anthropic client
client = anthropic.Anthropic(
    api_key=os.environ.get("ANTHROPIC_API_KEY")
)

@app.route('/')
def home():
    return jsonify({
        "status": "Co-Writer API is running",
        "version": "1.0.0"
    })

@app.route('/api/feedback', methods=['POST'])
def get_feedback():
    """
    Endpoint om AI feedback te krijgen op een tekst
    """
    try:
        data = request.get_json()
        
        if not data or 'text' not in data:
            response = jsonify({
                "error": "Geen tekst ontvangen"
            })
            response.headers.add('Access-Control-Allow-Origin', '*')
            return response, 400
        
        text = data['text']
        
        if not text.strip():
            response = jsonify({
                "error": "Tekst mag niet leeg zijn"
            })
            response.headers.add('Access-Control-Allow-Origin', '*')
            return response, 400
        
        # Create message with Anthropic API
        message = client.messages.create(
            model="claude-sonnet-4-20250514",
            max_tokens=1000,
            messages=[{
                "role": "user",
                "content": f"""Je bent een ervaren Nederlandse boekenschrijver en redacteur. Geef constructieve, professionele feedback op het volgende tekstfragment. Focus op:

1. Stijl en leesbaarheid
2. Dialoog en karakterontwikkeling (indien van toepassing)
3. Spanning en verhaalstructuur
4. Grammatica en woordkeuze
5. Concrete verbetervoorstellen

Wees bemoedigend maar eerlijk. Geef je feedback in duidelijke punten.

TEKST OM TE BEOORDELEN:
{text}"""
            }]
        )
        
        # Extract text from response
        feedback = ""
        for block in message.content:
            if block.type == "text":
                feedback += block.text
        
        response = jsonify({
            "feedback": feedback,
            "success": True
        })
        response.headers.add('Access-Control-Allow-Origin', '*')
        return response
        
    except anthropic.APIError as e:
        response = jsonify({
            "error": f"Anthropic API fout: {str(e)}",
            "success": False
        })
        response.headers.add('Access-Control-Allow-Origin', '*')
        return response, 500
        
    except Exception as e:
        response = jsonify({
            "error": f"Server fout: {str(e)}",
            "success": False
        })
        response.headers.add('Access-Control-Allow-Origin', '*')
        return response, 500

@app.route('/api/health', methods=['GET'])
def health_check():
    """Health check endpoint voor Render"""
    return jsonify({
        "status": "healthy",
        "api_key_configured": bool(os.environ.get("ANTHROPIC_API_KEY"))
    })

@app.route('/api/feedback', methods=['OPTIONS'])
def feedback_options():
    """Handle preflight OPTIONS request"""
    response = jsonify({'status': 'ok'})
    response.headers.add('Access-Control-Allow-Origin', '*')
    response.headers.add('Access-Control-Allow-Methods', 'POST, OPTIONS')
    response.headers.add('Access-Control-Allow-Headers', 'Content-Type')
    return response

if __name__ == '__main__':
    # Check if API key is set
    if not os.environ.get("ANTHROPIC_API_KEY"):
        print("⚠️  WAARSCHUWING: ANTHROPIC_API_KEY niet gevonden in environment variables!")
        print("    Zet deze in Render dashboard onder Environment Variables")
    
    # Run server
    port = int(os.environ.get("PORT", 5000))
    app.run(host='0.0.0.0', port=port, debug=False)
