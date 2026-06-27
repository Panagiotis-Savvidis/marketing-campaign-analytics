-- ============================================================================
-- SECTION 1: DATABASE & TABLES CREATION (DDL)
-- ============================================================================

DROP DATABASE IF EXISTS marketing_analytics;

CREATE DATABASE marketing_analytics;
USE marketing_analytics;


CREATE TABLE campaigns (
    id INT,
    campaign_type VARCHAR(50),
    channel VARCHAR(50),
    topic VARCHAR(255),
    started_at DATETIME(6),
    finished_at DATETIME(6),
    total_count INT,
    ab_test TINYINT,
    warmup_mode TINYINT,
    hour_limit INT,
    subject_length INT,
    subject_with_personalization TINYINT,
    subject_with_deadline TINYINT,
    subject_with_emoji TINYINT,
    subject_with_bonuses TINYINT,
    subject_with_discount TINYINT,
    subject_with_saleout TINYINT,
    is_test TINYINT,
    position VARCHAR(50),
    PRIMARY KEY (id, campaign_type)
);


CREATE TABLE client_first_purchase (
    client_id BIGINT PRIMARY KEY,                    
    first_purchase_date DATE
);


CREATE TABLE holidays (
    holiday_date DATE,
    holiday_name VARCHAR(255)
);


CREATE TABLE messages_demo (
    id INT NOT NULL,
    message_id VARCHAR(50) NOT NULL,
    campaign_id INT,                                
    message_type VARCHAR(50) NOT NULL,
    client_id BIGINT,
    channel VARCHAR(50),
    email_provider VARCHAR(50),
    stream VARCHAR(50),
    `date` DATE,
    sent_at DATETIME(6),
    is_opened TINYINT,                           
    opened_first_time_at DATETIME(6),
    opened_last_time_at DATETIME(6),
    is_clicked TINYINT,                          
    clicked_first_time_at DATETIME(6),
    clicked_last_time_at DATETIME(6),
    is_unsubscribed TINYINT,                     
    unsubscribed_at DATETIME(6),
    is_hard_bounced TINYINT,                     
    hard_bounced_at DATETIME(6),
    is_soft_bounced TINYINT,                     
    soft_bounced_at DATETIME(6),
    is_complained TINYINT,                       
    complained_at DATETIME(6),
    is_blocked TINYINT,                          
    blocked_at DATETIME(6),
    is_purchased TINYINT,                        
    purchased_at DATETIME(6),
    created_at DATETIME(6),
    updated_at DATETIME(6),
    PRIMARY KEY (id)
);


-- ============================================================================
-- SECTION 2: DATA LOADING & CLEANING (ETL)
-- ============================================================================

SET GLOBAL local_infile = 1;


LOAD DATA LOCAL INFILE '/Users/panagiotissavvidis/Documents/marketing_data/Dataset/campaigns.csv' 
INTO TABLE campaigns 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    id,
    campaign_type,
    channel,
    topic,
    @v_started_at,
    @v_finished_at,
    @v_total_count,
    @v_ab_test,
    @v_warmup_mode,
    @v_hour_limit,
    @v_subject_length,
    @v_subject_with_personalization,
    @v_subject_with_deadline,
    @v_subject_with_emoji,
    @v_subject_with_bonuses,
    @v_subject_with_discount,
    @v_subject_with_saleout,
    @v_is_test,
    position
)
SET 
    started_at = STR_TO_DATE(NULLIF(NULLIF(@v_started_at, ''), 'NaN'), '%Y-%m-%d %H:%i:%s.%f'),
    finished_at = STR_TO_DATE(NULLIF(NULLIF(@v_finished_at, ''), 'NaN'), '%Y-%m-%d %H:%i:%s.%f'),
    total_count   = FLOOR(CAST(NULLIF(NULLIF(@v_total_count, ''), 'NaN') AS DECIMAL(10,2))),
    hour_limit    = FLOOR(CAST(NULLIF(NULLIF(@v_hour_limit, ''), 'NaN') AS DECIMAL(10,2))),
    subject_length = FLOOR(CAST(NULLIF(NULLIF(@v_subject_length, ''), 'NaN') AS DECIMAL(10,2))),
    ab_test = CASE WHEN @v_ab_test = 'True' THEN 1 WHEN @v_ab_test = 'False' THEN 0 ELSE NULL END,
    warmup_mode = CASE WHEN @v_warmup_mode = 'True' THEN 1 WHEN @v_warmup_mode = 'False' THEN 0 ELSE NULL END,
    subject_with_personalization = CASE WHEN @v_subject_with_personalization = 'True' THEN 1 WHEN @v_subject_with_personalization = 'False' THEN 0 ELSE NULL END,
    subject_with_deadline = CASE WHEN @v_subject_with_deadline = 'True' THEN 1 WHEN @v_subject_with_deadline = 'False' THEN 0 ELSE NULL END,
    subject_with_emoji = CASE WHEN @v_subject_with_emoji = 'True' THEN 1 WHEN @v_subject_with_emoji = 'False' THEN 0 ELSE NULL END,
    subject_with_bonuses = CASE WHEN @v_subject_with_bonuses = 'True' THEN 1 WHEN @v_subject_with_bonuses = 'False' THEN 0 ELSE NULL END,
    subject_with_discount = CASE WHEN @v_subject_with_discount = 'True' THEN 1 WHEN @v_subject_with_discount = 'False' THEN 0 ELSE NULL END,
    subject_with_saleout = CASE WHEN @v_subject_with_saleout = 'True' THEN 1 WHEN @v_subject_with_saleout = 'False' THEN 0 ELSE NULL END,
    is_test = CASE WHEN @v_is_test = 'True' THEN 1 WHEN @v_is_test = 'False' THEN 0 ELSE NULL END;
    
    
LOAD DATA LOCAL INFILE '/Users/panagiotissavvidis/Documents/marketing_data/Dataset/client_first_purchase_date.csv' 
INTO TABLE client_first_purchase 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;


LOAD DATA LOCAL INFILE '/Users/panagiotissavvidis/Documents/marketing_data/Dataset/holidays.csv' 
INTO TABLE holidays 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;


LOAD DATA LOCAL INFILE '/Users/panagiotissavvidis/Documents/marketing_data/Dataset/messages-demo.csv'  
INTO TABLE messages_demo    
FIELDS TERMINATED BY ','   
ENCLOSED BY '"'  
LINES TERMINATED BY '\n'  
IGNORE 1 LINES   
(     
    id,      
    message_id,      
    @v_campaign_id,                                 
    message_type,      
    client_id,      
    channel,      
    @dummy_category,  -- discard empty columns
    @dummy_platform,  -- discard empty columns
    email_provider,      
    stream,      
    @v_date,      
    @v_sent_at,      
    @v_is_opened,                                   
    @v_opened_first_time_at,      
    @v_opened_last_time_at,      
    @v_is_clicked,                                  
    @v_clicked_first_time_at,      
    @v_clicked_last_time_at,      
    @v_is_unsubscribed,                             
    @v_unsubscribed_at,      
    @v_is_hard_bounced,                             
    @v_hard_bounced_at,      
    @v_is_soft_bounced,                             
    @v_soft_bounced_at,      
    @v_is_complained,                               
    @v_complained_at,      
    @v_is_blocked,                                  
    @v_blocked_at,      
    @v_is_purchased,                                
    @v_purchased_at,      
    @v_created_at,      
    @v_updated_at 
)    
SET      
    campaign_id           = CAST(NULLIF(NULLIF(@v_campaign_id, ''), 'NaN') AS UNSIGNED),
    `date`                = STR_TO_DATE(NULLIF(@v_date, ''), '%Y-%m-%d'),      
    sent_at               = STR_TO_DATE(NULLIF(@v_sent_at, ''), '%Y-%m-%d %H:%i:%s.%f'),      
    opened_first_time_at  = STR_TO_DATE(NULLIF(@v_opened_first_time_at, ''), '%Y-%m-%d %H:%i:%s.%f'),      
    opened_last_time_at   = STR_TO_DATE(NULLIF(@v_opened_last_time_at, ''), '%Y-%m-%d %H:%i:%s.%f'),      
    clicked_first_time_at = STR_TO_DATE(NULLIF(@v_clicked_first_time_at, ''), '%Y-%m-%d %H:%i:%s.%f'),      
    clicked_last_time_at  = STR_TO_DATE(NULLIF(@v_clicked_last_time_at, ''), '%Y-%m-%d %H:%i:%s.%f'),      
    unsubscribed_at       = STR_TO_DATE(NULLIF(@v_unsubscribed_at, ''), '%Y-%m-%d %H:%i:%s.%f'),      
    hard_bounced_at       = STR_TO_DATE(NULLIF(@v_hard_bounced_at, ''), '%Y-%m-%d %H:%i:%s.%f'),      
    soft_bounced_at       = STR_TO_DATE(NULLIF(@v_soft_bounced_at, ''), '%Y-%m-%d %H:%i:%s.%f'),      
    complained_at         = STR_TO_DATE(NULLIF(@v_complained_at, ''), '%Y-%m-%d %H:%i:%s.%f'),      
    blocked_at            = STR_TO_DATE(NULLIF(@v_blocked_at, ''), '%Y-%m-%d %H:%i:%s.%f'),      
    purchased_at          = STR_TO_DATE(NULLIF(@v_purchased_at, ''), '%Y-%m-%d %H:%i:%s.%f'),      
    created_at            = STR_TO_DATE(NULLIF(@v_created_at, ''), '%Y-%m-%d %H:%i:%s.%f'),      
    updated_at            = STR_TO_DATE(NULLIF(@v_updated_at, ''), '%Y-%m-%d %H:%i:%s.%f'),

    is_opened       = CASE WHEN @v_is_opened = 't' THEN 1 WHEN @v_is_opened = 'f' THEN 0 ELSE NULL END,
    is_clicked      = CASE WHEN @v_is_clicked = 't' THEN 1 WHEN @v_is_clicked = 'f' THEN 0 ELSE NULL END,
    is_unsubscribed = CASE WHEN @v_is_unsubscribed = 't' THEN 1 WHEN @v_is_unsubscribed = 'f' THEN 0 ELSE NULL END,
    is_hard_bounced = CASE WHEN @v_is_hard_bounced = 't' THEN 1 WHEN @v_is_hard_bounced = 'f' THEN 0 ELSE NULL END,
    is_soft_bounced = CASE WHEN @v_is_soft_bounced = 't' THEN 1 WHEN @v_is_soft_bounced = 'f' THEN 0 ELSE NULL END,
    is_complained   = CASE WHEN @v_is_complained = 't' THEN 1 WHEN @v_is_complained = 'f' THEN 0 ELSE NULL END,
    is_blocked      = CASE WHEN @v_is_blocked = 't' THEN 1 WHEN @v_is_blocked = 'f' THEN 0 ELSE NULL END,
    is_purchased    = CASE WHEN @v_is_purchased = 't' THEN 1 WHEN @v_is_purchased = 'f' THEN 0 ELSE NULL END;


ALTER TABLE messages_demo ADD INDEX idx_campaign (campaign_id);
ALTER TABLE messages_demo ADD INDEX idx_client (client_id);


-- ============================================================================
-- SECTION 3: DATA AGGREGATION & BUSINESS LOGIC
-- ============================================================================

SELECT
    CONCAT(m.campaign_id, '_', c.campaign_type) AS campaign_key,
    m.campaign_id,
    c.campaign_type,
    c.channel AS campaign_channel,
    m.channel AS message_channel,
    c.topic,
    m.`date`,

    IF(h.holiday_date IS NOT NULL, 1, 0) AS is_holiday,
    COALESCE(h.holiday_name, 'Regular Day') AS holiday_name,

    COUNT(m.id) AS total_messages_sent,
    SUM(m.is_opened) AS total_opens,
    SUM(m.is_clicked) AS total_clicks,
    SUM(m.is_unsubscribed) AS total_unsubscribes,
    SUM(m.is_hard_bounced + m.is_soft_bounced) AS total_bounces,
    SUM(m.is_purchased) AS total_purchases

FROM messages_demo m

INNER JOIN campaigns c
    ON m.campaign_id = c.id
    AND m.message_type = c.campaign_type

LEFT JOIN holidays h
    ON m.`date` = h.holiday_date

WHERE
    c.is_test = 0
    OR c.is_test IS NULL

GROUP BY
    m.campaign_id,
    c.campaign_type,
    c.channel,
    m.channel,
    c.topic,
    m.`date`,
    h.holiday_date,
    h.holiday_name;