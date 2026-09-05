use futures_util::StreamExt;
use reqwest::Client;
use serde::{Deserialize, Serialize};
use std::time::Instant;
use tauri::{AppHandle, Emitter};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ModelInfo {
    pub id: String,
    pub display_name: String,
    pub description: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PingResult {
    pub success: bool,
    pub latency_ms: u64,
    pub models: Vec<ModelInfo>,
    pub error: Option<String>,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum AiAction {
    Translate,
    Grammar,
    Summarize,
    Explain,
}

impl AiAction {
    pub fn title(&self) -> &'static str {
        match self {
            AiAction::Translate => "Умный перевод",
            AiAction::Grammar => "Грамматика и стиль",
            AiAction::Summarize => "Суммаризация",
            AiAction::Explain => "Анализ и объяснение",
        }
    }

    pub fn badge(&self) -> &'static str {
        match self {
            AiAction::Translate => "Alt + T",
            AiAction::Grammar => "Alt + G",
            AiAction::Summarize => "Alt + S",
            AiAction::Explain => "Alt + E",
        }
    }

    pub fn build_prompt(&self, text: &str, target_lang: &str) -> String {
        match self {
            AiAction::Translate => {
                format!(
                    "You are a professional, accurate translator. \
Translate the following text faithfully and naturally. \
Target language: '{target_lang}'. If the input text is already in '{target_lang}', translate it to English. \
Output ONLY the translated text without commentary, pleasantries, or quotes:\n\n{text}"
                )
            }
            AiAction::Grammar => {
                format!(
                    "You are an expert editor and linguist. \
Fix all spelling, grammar, punctuation, and phrasing issues in the following text while strictly preserving its original meaning and tone. \
Output ONLY the corrected and polished version without preamble, explanations, or quotes:\n\n{text}"
                )
            }
            AiAction::Summarize => {
                format!(
                    "You are an executive summarizer. \
Summarize the key points of the following text in 2 to 3 concise, clear bullet points. \
Use the same language as the input text. Output ONLY the summary bullets:\n\n{text}"
                )
            }
            AiAction::Explain => {
                format!(
                    "You are a helpful senior developer and knowledge expert. \
Explain the following text, term, idiom, code snippet, or error message clearly, practically, and concisely in Russian. \
If it is code or an error, explain the cause and how to fix it. Output the explanation in clean markdown:\n\n{text}"
                )
            }
        }
    }
}

pub async fn list_models(api_key: &str) -> Result<Vec<ModelInfo>, String> {
    if api_key.trim().is_empty() {
        return Err("API ключ не указан".into());
    }

    let client = Client::builder()
        .timeout(std::time::Duration::from_secs(12))
        .build()
        .map_err(|e| format!("Client error: {}", e))?;

    let url = format!(
        "https://generativelanguage.googleapis.com/v1beta/models?key={}",
        api_key.trim()
    );

    let resp = client
        .get(&url)
        .send()
        .await
        .map_err(|e| format!("Ошибка подключения к Google API: {}", e))?;

    if !resp.status().is_success() {
        let status = resp.status();
        let body = resp.text().await.unwrap_or_default();
        if status.as_u16() == 400 || status.as_u16() == 403 {
            return Err("Неверный API-ключ Gemini или доступ ограничен".into());
        }
        return Err(format!("Ошибка Google API ({status}): {body}"));
    }

    #[derive(Deserialize)]
    struct RawModel {
        name: String,
        #[serde(rename = "displayName")]
        display_name: Option<String>,
        description: Option<String>,
        #[serde(rename = "supportedGenerationMethods")]
        supported_generation_methods: Option<Vec<String>>,
    }

    #[derive(Deserialize)]
    struct ModelsResponse {
        models: Option<Vec<RawModel>>,
    }

    let data: ModelsResponse = resp
        .json()
        .await
        .map_err(|e| format!("Ошибка разбора списка моделей: {}", e))?;

    let mut result = Vec::new();
    if let Some(raw_models) = data.models {
        for m in raw_models {
            let methods = m.supported_generation_methods.unwrap_or_default();
            if methods.iter().any(|method| method == "generateContent") {
                let id = m.name.trim_start_matches("models/").to_string();
                let display_name = m.display_name.unwrap_or_else(|| id.clone());
                let description = m.description.unwrap_or_default();
                result.push(ModelInfo {
                    id,
                    display_name,
                    description,
                });
            }
        }
    }

    // Sort models so that gemini-2.5-flash, gemini-2.0-flash, gemini-1.5-flash appear first
    result.sort_by(|a, b| {
        let score = |name: &str| -> i32 {
            if name.contains("2.5-flash") {
                100
            } else if name.contains("2.0-flash") {
                90
            } else if name.contains("1.5-flash") {
                80
            } else if name.contains("1.5-pro") {
                70
            } else if name.contains("flash") {
                60
            } else {
                10
            }
        };
        score(&b.id).cmp(&score(&a.id))
    });

    Ok(result)
}

pub async fn ping_api_key(api_key: &str) -> PingResult {
    let start = Instant::now();
    match list_models(api_key).await {
        Ok(models) => PingResult {
            success: true,
            latency_ms: start.elapsed().as_millis() as u64,
            models,
            error: None,
        },
        Err(e) => PingResult {
            success: false,
            latency_ms: start.elapsed().as_millis() as u64,
            models: default_fallback_models(),
            error: Some(e),
        },
    }
}

pub fn default_fallback_models() -> Vec<ModelInfo> {
    vec![
        ModelInfo {
            id: "gemini-2.5-flash".into(),
            display_name: "Gemini 2.5 Flash (Рекомендуемая)".into(),
            description: "Самая быстрая и интеллектуальная модель нового поколения".into(),
        },
        ModelInfo {
            id: "gemini-2.0-flash".into(),
            display_name: "Gemini 2.0 Flash".into(),
            description: "Высокая скорость и низкая задержка".into(),
        },
        ModelInfo {
            id: "gemini-1.5-flash".into(),
            display_name: "Gemini 1.5 Flash".into(),
            description: "Проверенная стабильная скоростная модель".into(),
        },
        ModelInfo {
            id: "gemini-1.5-pro".into(),
            display_name: "Gemini 1.5 Pro".into(),
            description: "Максимальное качество и глубокий контекст".into(),
        },
    ]
}

#[derive(Serialize)]
struct GenerateRequest<'a> {
    contents: Vec<ContentPart<'a>>,
}

#[derive(Serialize)]
struct ContentPart<'a> {
    parts: Vec<TextPart<'a>>,
}

#[derive(Serialize)]
struct TextPart<'a> {
    text: &'a str,
}

#[derive(Deserialize)]
struct StreamCandidate {
    content: Option<CandidateContent>,
}

#[derive(Deserialize)]
struct CandidateContent {
    parts: Option<Vec<CandidatePart>>,
}

#[derive(Deserialize)]
struct CandidatePart {
    text: Option<String>,
}

#[derive(Deserialize)]
struct StreamChunk {
    candidates: Option<Vec<StreamCandidate>>,
}

/// Executes real-time streaming translation and emits tokens to the HUD window.
pub async fn execute_streaming_action(
    app: &AppHandle,
    api_key: &str,
    model: &str,
    action: AiAction,
    source_text: &str,
    target_lang: &str,
) -> Result<String, String> {
    let client = Client::builder()
        .timeout(std::time::Duration::from_secs(30))
        .build()
        .map_err(|e| format!("Client build error: {}", e))?;

    let prompt = action.build_prompt(source_text, target_lang);

    let url = format!(
        "https://generativelanguage.googleapis.com/v1beta/models/{}:streamGenerateContent?alt=sse&key={}",
        model.trim(),
        api_key.trim()
    );

    let payload = GenerateRequest {
        contents: vec![ContentPart {
            parts: vec![TextPart { text: &prompt }],
        }],
    };

    let response = client
        .post(&url)
        .json(&payload)
        .send()
        .await
        .map_err(|e| format!("Сетевая ошибка запроса к Gemini: {}", e))?;

    if !response.status().is_success() {
        let status = response.status();
        let err_text = response.text().await.unwrap_or_default();
        let message = if status.as_u16() == 429 {
            "Превышен лимит запросов Google API (Rate Limit). Попробуйте через пару секунд.".to_string()
        } else if status.as_u16() == 400 || status.as_u16() == 403 {
            "Неверный API-ключ Gemini или доступ ограничен в вашем регионе.".to_string()
        } else {
            format!("Ошибка Gemini API ({status}): {err_text}")
        };

        let _ = app.emit("stream-error", &message);
        return Err(message);
    }

    let mut stream = response.bytes_stream();
    let mut full_accumulated = String::new();
    let mut buffer = String::new();

    while let Some(chunk_res) = stream.next().await {
        let bytes = chunk_res.map_err(|e| format!("Ошибка чтения потока токенов: {}", e))?;
        let text_chunk = String::from_utf8_lossy(&bytes);
        buffer.push_str(&text_chunk);

        while let Some(line_end) = buffer.find('\n') {
            let line = buffer[..line_end].trim().to_string();
            buffer = buffer[line_end + 1..].to_string();

            if line.starts_with("data:") {
                let json_data = line.trim_start_matches("data:").trim();
                if let Ok(parsed) = serde_json::from_str::<StreamChunk>(json_data) {
                    if let Some(candidates) = parsed.candidates {
                        for c in candidates {
                            if let Some(content) = c.content {
                                if let Some(parts) = content.parts {
                                    for p in parts {
                                        if let Some(token) = p.text {
                                            full_accumulated.push_str(&token);
                                            let _ = app.emit("stream-token", &token);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    let _ = app.emit("stream-complete", &full_accumulated);
    Ok(full_accumulated)
}
