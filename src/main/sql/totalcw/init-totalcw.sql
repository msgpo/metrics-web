-- Copyright 2018 The Tor Project
-- See LICENSE for licensing information

-- Table of v3 authorities that stores nicknames and identity fingerprints and
-- assigns much shorter numeric identifiers for internal-only use.
CREATE TABLE authority (

  -- The auto-incremented numeric identifier for an authority.
  authority_id SERIAL PRIMARY KEY,

  -- The 1 to 19 character long alphanumeric nickname assigned to the authority by
  -- its operator.
  nickname CHARACTER VARYING(19) NOT NULL,

  -- Uppercase hex fingerprint of the authority's (v3 authority) identity key.
  identity_hex CHARACTER(40) NOT NULL,

  UNIQUE (nickname, identity_hex)
);

-- Table of all votes with statistics on contained bandwidth measurements. Only
-- contains votes containing bandwidth measurements.
CREATE TABLE vote (

  -- The auto-incremented numeric identifier for a vote.
  vote_id SERIAL PRIMARY KEY,

  -- Timestamp at which the consensus is supposed to become valid.
  valid_after TIMESTAMP WITHOUT TIME ZONE NOT NULL,

  -- Numeric identifier uniquely identifying the authority generating this vote.
  authority_id INTEGER REFERENCES authority (authority_id),

  -- Count of status entries containing bandwidth measurements.
  measured_count BIGINT NOT NULL,

  -- Sum of bandwidth measurements of all contained status entries.
  measured_sum BIGINT NOT NULL,

  -- Mean value of bandwidth measurements of all contained status entries.
  measured_mean BIGINT NOT NULL,

  -- Minimum value of bandwidth measurements of all contained status entries.
  measured_min BIGINT NOT NULL,

  -- First quartile value of bandwidth measurements of all contained status
  -- entries.
  measured_q1 BIGINT NOT NULL,

  -- Median value of bandwidth measurements of all contained status entries.
  measured_median BIGINT NOT NULL,

  -- Third quartile value of bandwidth measurements of all contained status
  -- entries.
  measured_q3 BIGINT NOT NULL,

  -- Maximum value of bandwidth measurements of all contained status entries.
  measured_max BIGINT NOT NULL,

  UNIQUE (valid_after, authority_id)
);

-- View on aggregated total consensus weight statistics in a format that is
-- compatible for writing to an output CSV file. Votes are only included in the
-- output if at least 12 votes are known for a given authority and day.
CREATE OR REPLACE VIEW totalcw AS
SELECT DATE(valid_after) AS valid_after_date, nickname,
  FLOOR(AVG(measured_sum)) AS measured_sum_avg
FROM vote NATURAL JOIN authority
GROUP BY DATE(valid_after), nickname
HAVING COUNT(vote_id) >= 12
  AND DATE(valid_after) < (SELECT MAX(DATE(valid_after)) FROM vote)
ORDER BY DATE(valid_after), nickname;
