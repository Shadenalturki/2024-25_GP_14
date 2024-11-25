from flask import Flask, request, jsonify
from flask_ngrok import run_with_ngrok
from transformers import AutoTokenizer, AutoModelForCausalLM, pipeline, BitsAndBytesConfig
from langchain_community.document_loaders import PyPDFLoader
from io import BytesIO
import tempfile
import torch
app = Flask(__name__)
run_with_ngrok(app)  # Start ngrok when app is run# Initialize the model using HuggingFace

from transformers import AutoTokenizer, AutoModelForCausalLM
import torch
model_name = "meta-llama/Meta-Llama-3-8B-Instruct"
quantization_config = BitsAndBytesConfig(
    load_in_4bit=True,
    bnb_4bit_compute_dtype=torch.bfloat16
)

tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForCausalLM.from_pretrained(
    model_name,
    quantization_config=quantization_config,
    trust_remote_code=True,
    device_map="auto"
)


text_generator = pipeline(
    "text-generation",
    model=model,
    tokenizer=tokenizer,
    device_map="auto",
    torch_dtype="bfloat16",
    trust_remote_code=True
)
import os
import traceback
from flask import Flask, request, jsonify
from io import BytesIO
import tempfile
from langchain_community.document_loaders import PyPDFLoader

#def rearrange_text(text):
    # Custom logic to rearrange the text
    # Example: Sort words alphabetically
   # words = text.split()
    #rearranged_text = " ".join(sorted(words))
    #return rearranged_text

# Route to handle file upload
@app.route('/upload', methods=['POST'])
def upload_pdf():
    if 'file' not in request.files:
        return jsonify({"error": "No file uploaded"}), 400

    file = request.files['file']
    if not file.filename.endswith('.pdf'):
        return jsonify({"error": "Only PDF files are allowed"}), 400

    try:
        # Load the PDF and extract text
        pdf_file = BytesIO(file.read())
        with tempfile.NamedTemporaryFile(delete=False, suffix=".pdf") as temp_pdf_file:
            temp_pdf_file.write(pdf_file.getvalue())
            temp_pdf_file_path = temp_pdf_file.name

        try:
            loader = PyPDFLoader(temp_pdf_file_path)
            documents = loader.load()
            extracted_text = " ".join([doc.page_content for doc in documents])

            # Apply rearrangement logic
            #rearranged_text = rearrange_text(extracted_text)

            return jsonify({
                "message": "PDF processed successfully!",
                "extracted_text": extracted_text
            }), 200

        finally:
            # Ensure the temporary file is deleted
            if os.path.exists(temp_pdf_file_path):
                os.unlink(temp_pdf_file_path)

    except Exception as e:
        # Log the error with a full traceback
        print(f"Error processing PDF: {e}")
        traceback.print_exc()
        return jsonify({"error": f"Failed to process PDF. Error: {str(e)}"}), 500
# Route to summarize text
@app.route('/summarize', methods=['POST'])
def summarize():
    data = request.json
    if not data or 'text' not in data:
        return jsonify({"error": "No text provided"}), 400

    input_text = data['text']

    # Template for summarization
    template = """
       You are a summarizer tasked with condensing the provided text into a high-quality summary presented as bullet points.
       Your response should start immediately with the summary, avoiding any introductory remarks.
       The summary must:
       Cover all essential contents of the lesson.
       Be comprehensive enough to replace studying the slides.
       Simplify long definitions while maintaining accuracy and understanding.
       Include any enumerations, examples, or key points in a structured and logical order.
       Content: {text}

       Your Answer:
       (Summary starts directly here in bullet-point format.)
       """
    prompt = template.replace("{text}", input_text)

    # Generate summary
    sequences = text_generator(
        prompt,
        max_new_tokens=1024,
        do_sample=True,
        temperature=0.3,
        num_return_sequences=1,
        repetition_penalty=1.2,
        return_full_text=False
    )

    generated_summary = sequences[0]['generated_text']
    return jsonify({"summary": generated_summary})
# Start Flask server
if __name__ == '__main__':
    from google.colab.output import eval_js
    from pyngrok import ngrok
    ngrok.kill()
    public_url = ngrok.connect("5000")

    print(f"Custom Ngrok URL: {public_url}")
    # Setup ngrok
    #ngrok_tunnel = ngrok.connect(5000)
 app.run()    #print(f"Public URL: {ngrok_tunnel.public_url}")